import { Hono } from 'hono';

const premiumContent = new Hono();

/**
 * Premium content API endpoint
 * @param c - Hono context
 * @returns Premium content response
 */
premiumContent.get('/', (c) => {
  return c.json({
    content: 'This is premium content that requires payment to access',
    features: [
      'Exclusive data insights',
      'Advanced analytics',
      'Priority support',
      'Custom integrations',
    ],
    timestamp: new Date().toISOString(),
  });
});

export default premiumContent;
