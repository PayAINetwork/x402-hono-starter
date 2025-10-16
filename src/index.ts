import { Hono } from 'hono';
import { paymentMiddleware } from 'x402-hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { serveStatic } from 'hono/bun';

// Import routes
import weatherRoute from './routes/api/weather';
import premiumContentRoute from './routes/api/premium/content';
import homeRoute from './routes/home';
import premiumPageRoute from './routes/premium';

const app = new Hono();

// Middleware
app.use('*', cors());
app.use('*', logger());

// Payment middleware configuration
const paymentConfig = {
  '/api/weather': {
    // USDC amount in dollars
    price: '$0.001',
    // network: "base" // uncomment for Base mainnet
    // network: "solana" // uncomment for Solana mainnet
    network: 'base-sepolia',
  },
  '/api/premium/*': {
    // Define atomic amounts in any EIP-3009 token
    price: {
      amount: '100000',
      asset: {
        address: '0xabc',
        decimals: 18,
        // omit eip712 for Solana
        eip712: {
          name: 'WETH',
          version: '1',
        },
      },
    },
    // network: "base" // uncomment for Base mainnet
    // network: "solana" // uncomment for Solana mainnet
    network: 'base-sepolia',
  },
};

const facilitatorConfig = {
  url: process.env.FACILITATOR_URL as string,
};

// Apply payment middleware
app.use(
  '/api/weather',
  paymentMiddleware(
    process.env.RESOURCE_WALLET_ADDRESS as `0x${string}`,
    paymentConfig,
    facilitatorConfig
  )
);

app.use(
  '/api/premium/*',
  paymentMiddleware(
    process.env.RESOURCE_WALLET_ADDRESS as `0x${string}`,
    paymentConfig,
    facilitatorConfig
  )
);

// Static files
app.use('/styles/*', serveStatic({ root: './src' }));

// Routes
app.route('/', homeRoute);
app.route('/premium', premiumPageRoute);
app.route('/api/weather', weatherRoute);
app.route('/api/premium', premiumContentRoute);

const port = process.env.PORT || 3000;

console.log(`🚀 Server running on http://localhost:${port}`);

export default {
  port,
  fetch: app.fetch,
};
