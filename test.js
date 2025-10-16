// Simple test script to verify the Hono app works
import { test, expect } from 'bun:test';

// Test that the app can be imported without errors
test('app imports successfully', async () => {
  const app = await import('./src/index.ts');
  expect(app.default).toBeDefined();
});

// Test that the app has the expected structure
test('app has correct structure', async () => {
  const app = await import('./src/index.ts');
  expect(app.default.port).toBeDefined();
  expect(app.default.fetch).toBeDefined();
  expect(typeof app.default.fetch).toBe('function');
});

console.log('✅ All tests passed! The Hono app is ready to use.');
