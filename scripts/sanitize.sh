#!/usr/bin/env bash
set -euo pipefail
# This comment is a harmless no-op to ensure GitHub shows the script contents in PRs
UP_PATH="${1:-examples/typescript/servers/hono}"
UP_SHA="${2:-unknown}"

# Keep a mirror for reference (gitignored) and map into template root
mkdir -p vendor/upstream

# Map upstream into template root, preserving structure
mkdir -p template
rsync -a --delete vendor/upstream/ template/

# Replace workspace:* dependencies with actual npm packages
# and update package names from x402-hono to @x402/hono
if [[ -f template/package.json ]]; then
  node - <<'NODE'
const fs = require('fs');
const path = 'template/package.json';
const json = JSON.parse(fs.readFileSync(path, 'utf8'));

// Get x402 version from root package.json config
let x402Version = '2.2.0';
try {
  const rootPkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
  if (rootPkg.config && rootPkg.config.x402HonoVersion) {
    x402Version = rootPkg.config.x402HonoVersion;
  }
} catch (e) {}

const deps = json.dependencies || {};

// Remove workspace:* dependencies (like @coinbase/x402)
for (const [name, version] of Object.entries(deps)) {
  if (typeof version === 'string' && version.startsWith('workspace:')) {
    delete deps[name];
  }
}

// Replace old x402-hono with @x402/hono
if (deps['x402-hono']) {
  delete deps['x402-hono'];
}

// Add all required @x402/* packages with the configured version
const x402Packages = ['@x402/hono', '@x402/evm', '@x402/svm', '@x402/core', '@x402/extensions'];
for (const pkg of x402Packages) {
  deps[pkg] = '^' + x402Version;
}

json.dependencies = deps;
fs.writeFileSync(path, JSON.stringify(json, null, 2));
console.log('Updated template/package.json: replaced workspace deps, using @x402/*@^' + x402Version);
NODE
fi

# Update imports in template files from x402-hono to @x402/hono
if [[ -f template/index.ts ]]; then
  sed -i.bak 's/from "x402-hono"/from "@x402\/hono"/g' template/index.ts && rm -f template/index.ts.bak
  sed -i.bak "s/from 'x402-hono'/from '@x402\/hono'/g" template/index.ts && rm -f template/index.ts.bak
fi

# add the payai facilitator URL and NETWORK in env templates after sync
DEFAULT_FACILITATOR_URL="https://facilitator.payai.network"
DEFAULT_NETWORK="solana-devnet"

# Replace or append a key=value in the provided file. Creates the file if explicitly requested.
update_env_var() {
  local file="$1"
  local key="$2"
  local value="$3"
  local create_if_missing="${4:-false}"

  if [[ ! -f "$file" && "$create_if_missing" == "true" ]]; then
    mkdir -p "$(dirname "$file")"
    : > "$file"
  fi

  if [[ -f "$file" ]]; then
    if grep -Eq "^[[:space:]]*${key}=" "$file"; then
      # Replace existing non-commented line for the key
      sed -i.bak -E "s|^[[:space:]]*${key}=.*|${key}=${value}|" "$file" && rm -f "$file.bak"
    else
      printf "\n%s=%s\n" "$key" "$value" >> "$file"
    fi
  fi
}

# Cover common env file variants for Hono starters (update if they exist)
ENV_CANDIDATES=(
  "template/.env"
  "template/.env.local"
  "template/.env.development"
  "template/.env.example"
  "template/.env.local.example"
  "template/.env.sample"
  "template/env.local"
  "template/env.example"
  "template/.env-local"
)

for env_file in "${ENV_CANDIDATES[@]}"; do
  update_env_var "$env_file" "FACILITATOR_URL" "$DEFAULT_FACILITATOR_URL"
  update_env_var "$env_file" "NETWORK" "$DEFAULT_NETWORK"
done

# Ensure a canonical env.local exists with our expected defaults
if [[ ! -f template/env.local ]]; then
  update_env_var "template/env.local" "FACILITATOR_URL" "$DEFAULT_FACILITATOR_URL" true
  update_env_var "template/env.local" "NETWORK" "$DEFAULT_NETWORK" true
fi

# Refresh NOTICE with the commit we synced from
cat > NOTICE <<EOF
This package includes portions derived from coinbase/x402 (${UP_PATH}), Apache-2.0,
commit ${UP_SHA}. See LICENSE and upstream LICENSE notices.
EOF

# Cleanup transient directories so they don't get committed
rm -rf vendor/upstream || true
rm -rf upstream || true

echo "Sanitization complete."
