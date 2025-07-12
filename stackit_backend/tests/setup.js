/**
 * Jest setup file
 * This file runs before each test suite
 */

// Mock database module
jest.mock('../config/database', () => {
  return {
    query: jest.fn().mockImplementation(() => ({
      rows: [{ id: 1, username: 'testuser', email: 'test@example.com' }],
      rowCount: 1
    })),
    pool: {
      connect: jest.fn(),
      query: jest.fn(),
      end: jest.fn(),
      on: jest.fn()
    },
    getClient: jest.fn().mockReturnValue({
      query: jest.fn(),
      release: jest.fn()
    }),
    transaction: jest.fn(),
    batch: jest.fn(),
    checkPoolHealth: jest.fn().mockResolvedValue({ status: 'healthy' })
  };
});

// Mock other services and utilities
jest.mock('../utils/caching', () => {
  return {
    get: jest.fn(),
    set: jest.fn(),
    del: jest.fn(),
    clear: jest.fn(),
    stats: jest.fn().mockReturnValue({ hits: 0, misses: 0 }),
    keys: jest.fn(),
    DEFAULT_TTL: 300,
    cacheMiddleware: (ttl, keyFn) => (req, res, next) => next()
  };
});

jest.mock('../config/jwt', () => {
  return {
    JWT_SECRET: 'test-secret',
    JWT_EXPIRES_IN: '1h',
    generateToken: jest.fn().mockReturnValue('mocked-jwt-token'),
    verifyToken: jest.fn().mockReturnValue({
      userId: 1,
      username: 'testuser',
      role: 'user'
    }),
    extractTokenFromHeader: jest.fn().mockReturnValue('mocked-jwt-token')
  };
});

jest.mock('../utils/logger', () => {
  return {
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
    debug: jest.fn()
  };
});

// Setup global test environment
process.env.NODE_ENV = 'test';

// Silence console during tests
global.console = {
  ...console,
  log: jest.fn(),
  error: jest.fn(),
  warn: jest.fn(),
  info: jest.fn(),
  debug: jest.fn(),
}; 