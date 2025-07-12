/**
 * Jest test setup file
 * This file sets up the test environment before running tests
 */

// Set environment variables for testing
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret';
process.env.PORT = 5000;

// Mock database connection
jest.mock('../config/database', () => {
  // Create a mock database module
  const mockDb = {
    query: jest.fn().mockImplementation((text, params) => {
      // Default mock behavior for any query
      return Promise.resolve({ rows: [], rowCount: 0 });
    }),
    connectDB: jest.fn().mockResolvedValue(),
    closeDB: jest.fn().mockResolvedValue(),
  };

  return mockDb;
});

// Silence console logs during tests unless in verbose mode
if (!process.env.VERBOSE) {
  global.console = {
    ...console,
    log: jest.fn(),
    debug: jest.fn(),
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  };
} 