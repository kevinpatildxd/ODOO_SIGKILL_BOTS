/**
 * Jest configuration file
 */
module.exports = {
  // The test environment that will be used for testing
  testEnvironment: 'node',
  
  // Automatically clear mock calls and instances between every test
  clearMocks: true,
  
  // The glob patterns Jest uses to detect test files
  testMatch: ['**/__tests__/**/*.js?(x)', '**/?(*.)+(spec|test).js?(x)'],
  
  // An array of regexp pattern strings that are matched against all test paths
  // matched tests are skipped
  testPathIgnorePatterns: ['/node_modules/'],
  
  // Indicates whether each individual test should be reported during the run
  verbose: true,
  
  // A list of paths to directories that Jest should use to search for files in
  roots: ['<rootDir>'],
  
  // The directory where Jest should output its coverage files
  coverageDirectory: 'coverage',
  
  // An array of regexp pattern strings used to skip coverage collection
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/config/',
    '/tests/'
  ],
  
  // Indicates which provider should be used to instrument code for coverage
  coverageProvider: 'v8',
  
  // A list of reporter names that Jest uses when writing coverage reports
  coverageReporters: ['json', 'text', 'lcov', 'clover'],
  
  // The maximum amount of workers used to run tests
  maxWorkers: 1,
  
  // An array of file extensions your modules use
  moduleFileExtensions: ['js', 'json', 'node'],
  
  // A map from regular expressions to module names that allow to stub out resources
  moduleNameMapper: {},
  
  // Setup files after environment is set up
  setupFilesAfterEnv: [],
  
  // A list of paths to modules that run some code to configure the testing framework
  setupFiles: ['<rootDir>/tests/setup.js'],
  
  // The test timeout in milliseconds
  testTimeout: 10000,
}; 