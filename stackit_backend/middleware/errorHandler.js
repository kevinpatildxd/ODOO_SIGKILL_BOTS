/**
 * Centralized error handling middleware
 */
const logger = require('../utils/logger');
const { HTTP_STATUS } = require('../utils/constants');

/**
 * Custom error class for API errors
 * @class ApiError
 * @extends Error
 */
class ApiError extends Error {
  /**
   * Create a new ApiError
   * @param {String} message - Error message
   * @param {Number} statusCode - HTTP status code
   * @param {Object} data - Additional error data
   */
  constructor(message, statusCode = HTTP_STATUS.INTERNAL_SERVER_ERROR, data = {}) {
    super(message);
    this.statusCode = statusCode;
    this.data = data;
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Not found error handler middleware
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const notFoundHandler = (req, res, next) => {
  const error = new ApiError(`Resource not found - ${req.originalUrl}`, HTTP_STATUS.NOT_FOUND);
  next(error);
};

/**
 * Global error handler middleware
 * @param {Error} err - Error object
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const errorHandler = (err, req, res, next) => {
  // Default status code and error message
  const statusCode = err.statusCode || HTTP_STATUS.INTERNAL_SERVER_ERROR;
  const message = err.message || 'An unexpected error occurred';
  
  // Log the error (more detailed in development)
  if (statusCode >= HTTP_STATUS.INTERNAL_SERVER_ERROR) {
    logger.error(`Internal Server Error: ${message}`, {
      error: err.stack,
      url: req.originalUrl,
      method: req.method,
      body: req.body,
      params: req.params
    });
  } else {
    logger.warn(`Client Error: ${message}`, {
      statusCode,
      url: req.originalUrl,
      method: req.method
    });
  }
  
  // Create response object
  const errorResponse = {
    success: false,
    message,
    // Include stack trace in development but not in production
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  };
  
  // Include additional error data if available
  if (err.data) {
    errorResponse.data = err.data;
  }
  
  res.status(statusCode).json(errorResponse);
};

/**
 * Database error handler - converts database errors to friendly error responses
 * @param {Error} err - Database error
 * @param {String} operation - Operation being performed
 */
const handleDatabaseError = (err, operation = 'database operation') => {
  // Handle specific PostgreSQL error codes
  switch (err.code) {
    case '23505': // unique_violation
      return new ApiError(`Duplicate entry: ${err.detail}`, HTTP_STATUS.CONFLICT);
    case '23503': // foreign_key_violation
      return new ApiError(`Referenced resource not found: ${err.detail}`, HTTP_STATUS.BAD_REQUEST);
    case '23502': // not_null_violation
      return new ApiError(`Missing required field: ${err.column}`, HTTP_STATUS.BAD_REQUEST);
    case '22P02': // invalid_text_representation
      return new ApiError('Invalid data type provided', HTTP_STATUS.BAD_REQUEST);
    case '28P01': // invalid_password
      return new ApiError('Invalid credentials', HTTP_STATUS.UNAUTHORIZED);
    case '42P01': // undefined_table
      return new ApiError(`Database error: Table does not exist`, HTTP_STATUS.INTERNAL_SERVER_ERROR);
    default:
      return new ApiError(`Error during ${operation}`, HTTP_STATUS.INTERNAL_SERVER_ERROR);
  }
};

/**
 * Async handler to wrap async route handlers and catch errors
 * @param {Function} fn - Async function to wrap
 * @returns {Function} Express middleware function that catches errors
 */
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

module.exports = {
  ApiError,
  notFoundHandler,
  errorHandler,
  handleDatabaseError,
  asyncHandler
};
