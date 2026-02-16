#!/usr/bin/env bash
set -euo pipefail
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

# =============================================================================
# PayAI-specific patches (applied after upstream sync)
# =============================================================================

# --- index.ts: add @payai/facilitator import and replace facilitator client ---
if [[ -f template/index.ts ]]; then
  # Add the @payai/facilitator import after the last @x402 import
  if ! grep -q '@payai/facilitator' template/index.ts; then
    sed -i.bak '/^import.*@x402\/.*$/a\
import { facilitator } from "@payai/facilitator";' template/index.ts && rm -f template/index.ts.bak
    # De-duplicate in case multiple @x402 imports triggered multiple inserts
    awk '!seen[$0]++ || $0 !~ /@payai\/facilitator/' template/index.ts > template/index.ts.tmp \
      && mv template/index.ts.tmp template/index.ts
  fi

  # Remove FACILITATOR_URL env var check and manual client construction
  # Replace with: const facilitatorClient = new HTTPFacilitatorClient(facilitator);
  sed -i.bak '/^const facilitatorUrl/,/^const facilitatorClient/c\
const facilitatorClient = new HTTPFacilitatorClient(facilitator);' template/index.ts && rm -f template/index.ts.bak
fi

# --- package.json: ensure @payai/facilitator dependency is present ---
if [[ -f template/package.json ]]; then
  node <<'PATCH_DEPS'
  const fs = require('fs');
  const p = 'template/package.json';
  const j = JSON.parse(fs.readFileSync(p, 'utf8'));
  j.dependencies = j.dependencies || {};
  if (!j.dependencies['@payai/facilitator']) {
    j.dependencies['@payai/facilitator'] = '^2.2.4';
  }
  fs.writeFileSync(p, JSON.stringify(j, null, 2));
PATCH_DEPS
fi

# --- .env-local / .env.example: replace FACILITATOR_URL with API key vars ---
patch_env_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    return
  fi

  # Remove FACILITATOR_URL line if present
  sed -i.bak '/^FACILITATOR_URL=/d' "$file" && rm -f "$file.bak"

  # Remove NETWORK line if present (no longer needed)
  sed -i.bak '/^NETWORK=/d' "$file" && rm -f "$file.bak"

  # Add PayAI API key vars if not already present
  if ! grep -q 'PAYAI_API_KEY_ID' "$file"; then
    # Ensure file ends with newline before appending
    [[ -s "$file" ]] && [[ $(tail -c1 "$file") != $'\n' ]] && echo >> "$file"
    cat >> "$file" <<'ENVBLOCK'

# PayAI API Key for authenticated facilitator access (optional)
# Without these, the server works on the free tier.
# Get your keys at https://merchant.payai.network
# PAYAI_API_KEY_ID=
# PAYAI_API_KEY_SECRET=
ENVBLOCK
  fi
}

patch_env_file template/.env-local
patch_env_file template/.env.example

# Refresh NOTICE with the commit we synced from
cat > NOTICE <<EOF
This package includes portions derived from coinbase/x402 (${UP_PATH}), Apache-2.0,
commit ${UP_SHA}. See LICENSE and upstream LICENSE notices.
EOF

# Cleanup transient directories so they don't get committed
rm -rf vendor/upstream || true
rm -rf upstream || true

echo "Sanitization complete."
