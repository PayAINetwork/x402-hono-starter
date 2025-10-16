# x402 Hono Starter

A Hono application with x402 payment protocol integration, providing a modern web framework alternative to Next.js with the same payment functionality.

## Features

- **Hono Framework**: Fast, lightweight web framework for Bun/Node.js
- **x402 Payment Integration**: Built-in payment middleware for micro-payments
- **TypeScript Support**: Full TypeScript support with proper type definitions
- **Tailwind CSS**: Utility-first CSS framework for styling
- **API Routes**: RESTful API endpoints with payment protection
- **Static File Serving**: Built-in static file serving for assets

## Getting Started

### Prerequisites

- [Bun](https://bun.sh) installed on your system
- A crypto wallet with some test tokens
- Access to the x402 facilitator service

### Installation

1. Clone or download this starter template
2. Install dependencies:

```bash
bun install
```

3. Copy the environment file:

```bash
cp env.local .env.local
```

4. Update your environment variables in `.env.local`:

```env
# Replace with your actual wallet address
RESOURCE_WALLET_ADDRESS=YourAddress

# Facilitator URL
FACILITATOR_URL=https://facilitator.payai.network
```

5. Start the development server:

```bash
bun run dev
```

6. Open [http://localhost:3000](http://localhost:3000) in your browser

## Project Structure

```
src/
├── index.ts                 # Main application entry point
├── routes/
│   ├── home.tsx            # Home page route
│   ├── premium.tsx         # Premium content page
│   └── api/
│       ├── weather/        # Weather API endpoint
│       └── premium/
│           └── content/    # Premium content API
├── styles/
│   └── globals.css         # Global styles with Tailwind
└── ...
```

## API Endpoints

### Free Endpoints

- `GET /` - Home page
- `GET /premium` - Premium content page

### Protected Endpoints (Require Payment)

- `GET /api/weather` - Weather data (requires $0.001 USDC)
- `GET /api/premium/content` - Premium content (requires custom token payment)

## Payment Configuration

The payment middleware is configured in `src/index.ts`:

```typescript
const paymentConfig = {
  '/api/weather': {
    price: '$0.001',
    network: 'base-sepolia',
  },
  '/api/premium/*': {
    price: {
      amount: '100000',
      asset: {
        address: '0xabc',
        decimals: 18,
        eip712: {
          name: 'WETH',
          version: '1',
        },
      },
    },
    network: 'base-sepolia',
  },
};
```

## Available Scripts

- `bun run dev` - Start development server with hot reload
- `bun run build` - Build the application for production
- `bun run start` - Start the production server
- `bun run lint` - Run ESLint
- `bun run format` - Format code with Prettier
- `bun run format:check` - Check code formatting

## Development

The application uses:

- **Hono** for the web framework
- **x402-hono** for payment middleware
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **ESLint** and **Prettier** for code quality

## Deployment

The application can be deployed to any platform that supports Bun or Node.js:

1. Build the application: `bun run build`
2. Start the production server: `bun run start`

## License

This project is licensed under the same terms as the original x402-next-starter.
