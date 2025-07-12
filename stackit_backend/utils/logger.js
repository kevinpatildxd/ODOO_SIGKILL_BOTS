/**
 * Logger utility for consistent logging throughout the application
 */

// Get log level from environment variable
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';

// Log levels
const LOG_LEVELS = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4
};

// Check if the log should be displayed based on the current log level
const shouldLog = (level) => {
  return LOG_LEVELS[level] <= LOG_LEVELS[LOG_LEVEL];
};

// Format timestamp for logs
const getTimestamp = () => {
  return new Date().toISOString();
};

// Format log message
const formatMessage = (level, message, metadata = {}) => {
  return {
    timestamp: getTimestamp(),
    level,
    message,
    ...(Object.keys(metadata).length > 0 && { metadata })
  };
};

// Logger methods
const logger = {
  error: (message, metadata) => {
    if (shouldLog('error')) {
      console.error(JSON.stringify(formatMessage('error', message, metadata)));
    }
  },
  
  warn: (message, metadata) => {
    if (shouldLog('warn')) {
      console.warn(JSON.stringify(formatMessage('warn', message, metadata)));
    }
  },
  
  info: (message, metadata) => {
    if (shouldLog('info')) {
      console.info(JSON.stringify(formatMessage('info', message, metadata)));
    }
  },
  
  http: (message, metadata) => {
    if (shouldLog('http')) {
      console.log(JSON.stringify(formatMessage('http', message, metadata)));
    }
  },
  
  debug: (message, metadata) => {
    if (shouldLog('debug')) {
      console.debug(JSON.stringify(formatMessage('debug', message, metadata)));
    }
  }
};

module.exports = logger;
