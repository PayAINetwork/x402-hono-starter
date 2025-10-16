import { Hono } from 'hono';
import { html } from 'hono/html';

const premium = new Hono();

/**
 * Premium content page component
 * @param c - Hono context
 * @returns HTML response
 */
premium.get('/', (c) => {
  return c.html(html`
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Premium Content - x402 Hono App</title>
        <meta name="description" content="Access premium content with x402 payments" />
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="/styles/globals.css" />
      </head>
      <body>
        <main class="min-h-screen bg-gradient-to-br from-purple-50 to-pink-100 p-8">
          <div class="max-w-4xl mx-auto">
            <div class="text-center mb-12">
              <h1 class="text-5xl font-bold text-gray-900 mb-4">
                Premium Content
              </h1>
              <p class="text-xl text-gray-600 mb-8">
                This content is protected by x402 payment middleware
              </p>
            </div>

            <div class="bg-white rounded-lg shadow-lg p-8 mb-8">
              <h2 class="text-3xl font-semibold text-gray-800 mb-6">
                Exclusive Features
              </h2>
              <div class="grid md:grid-cols-2 gap-6">
                <div class="space-y-4">
                  <div class="flex items-center space-x-3">
                    <div class="w-2 h-2 bg-green-500 rounded-full"></div>
                    <span class="text-gray-700">Exclusive data insights</span>
                  </div>
                  <div class="flex items-center space-x-3">
                    <div class="w-2 h-2 bg-green-500 rounded-full"></div>
                    <span class="text-gray-700">Advanced analytics</span>
                  </div>
                  <div class="flex items-center space-x-3">
                    <div class="w-2 h-2 bg-green-500 rounded-full"></div>
                    <span class="text-gray-700">Priority support</span>
                  </div>
                  <div class="flex items-center space-x-3">
                    <div class="w-2 h-2 bg-green-500 rounded-full"></div>
                    <span class="text-gray-700">Custom integrations</span>
                  </div>
                </div>
                <div class="bg-gray-50 p-4 rounded-lg">
                  <h3 class="font-semibold text-gray-800 mb-2">API Access</h3>
                  <p class="text-sm text-gray-600 mb-3">
                    Access the premium API endpoint:
                  </p>
                  <code class="bg-gray-200 px-2 py-1 rounded text-sm">
                    GET /api/premium/content
                  </code>
                </div>
              </div>
            </div>

            <div class="bg-white rounded-lg shadow-lg p-8">
              <h2 class="text-2xl font-semibold text-gray-800 mb-4">
                How It Works
              </h2>
              <div class="space-y-4 text-gray-600">
                <p>
                  This page demonstrates x402 payment middleware integration. When you
                  access protected routes, the middleware will:
                </p>
                <ol class="list-decimal list-inside space-y-2 ml-4">
                  <li>Check if payment is required for the requested resource</li>
                  <li>Present payment options if no valid payment is found</li>
                  <li>Allow access once payment is verified</li>
                  <li>Cache payment status for subsequent requests</li>
                </ol>
              </div>
            </div>
          </div>
        </main>
      </body>
    </html>
  `);
});

export default premium;
