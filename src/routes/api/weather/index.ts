import { Hono } from 'hono';

const weather = new Hono();

/**
 * Weather API endpoint
 * @param c - Hono context
 * @returns Weather data response
 */
weather.get('/', (c) => {
  return c.json({
    report: {
      weather: 'sunny',
      temperature: 70,
      location: 'San Francisco, CA',
      timestamp: new Date().toISOString(),
    },
  });
});

export default weather;
