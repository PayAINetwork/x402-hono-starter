import { Hono } from 'hono';
import { html } from 'hono/html';

const home = new Hono();

/**
 * Home page component
 * @param c - Hono context
 * @returns HTML response
 */
home.get('/', (c) => {
  return c.html(html`
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>x402 Hono App</title>
        <meta name="description" content="A Hono application with x402 payment protocol integration" />
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="/styles/globals.css" />
      </head>
      <body>
        <main class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-8">
          <div class="max-w-4xl mx-auto">
            <div class="text-center mb-12">
              <h1 class="text-5xl font-bold text-gray-900 mb-4">
                Welcome to x402 Hono
              </h1>
              <p class="text-xl text-gray-600 mb-8">
                A Hono application with x402 payment protocol integration
              </p>
            </div>

            <div class="grid md:grid-cols-2 gap-8 mb-12">
              <div class="bg-white rounded-lg shadow-lg p-6">
                <h2 class="text-2xl font-semibold text-gray-800 mb-4">
                  Free Weather API
                </h2>
                <p class="text-gray-600 mb-4">
                  Get current weather information for free.
                </p>
                <a
                  href="/api/weather"
                  class="inline-block bg-blue-500 text-white px-6 py-2 rounded-lg hover:bg-blue-600 transition-colors"
                >
                  Try Weather API
                </a>
              </div>

              <div class="bg-white rounded-lg shadow-lg p-6">
                <h2 class="text-2xl font-semibold text-gray-800 mb-4">
                  Premium Content
                </h2>
                <p class="text-gray-600 mb-4">
                  Access premium content with x402 payments.
                </p>
                <a
                  href="/premium"
                  class="inline-block bg-green-500 text-white px-6 py-2 rounded-lg hover:bg-green-600 transition-colors"
                >
                  View Premium Content
                </a>
              </div>
            </div>

            <div class="bg-white rounded-lg shadow-lg p-6">
              <h2 class="text-2xl font-semibold text-gray-800 mb-4">
                Getting Started
              </h2>
              <div class="space-y-4 text-gray-600">
                <p>
                  1. Copy <code class="bg-gray-100 px-2 py-1 rounded">env.local</code> to{' '}
                  <code class="bg-gray-100 px-2 py-1 rounded">.env.local</code>
                </p>
                <p>
                  2. Update your wallet address and facilitator URL in the environment file
                </p>
                <p>3. Run <code class="bg-gray-100 px-2 py-1 rounded">bun run dev</code></p>
                <p>4. Visit the protected routes to test x402 payments</p>
              </div>
            </div>
          </div>
        </main>
      </body>
    </html>
  `);
});

export default home;
