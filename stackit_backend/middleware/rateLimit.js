/**
 * Rate limiting middleware for API protection
 */
const rateLimit = require('express-rate-limit');
const { HTTP_STATUS, RATE_LIMIT } = require('../utils/constants');

/**
 * Create a rate limiter with custom configuration
 * @param {Object} options - Rate limiting options
 * @returns {Function} Rate limiting middleware
 */
const createRateLimiter = (options = {}) => {
  const defaultOptions = {
    windowMs: RATE_LIMIT.WINDOW_MS, // Default window: 15 minutes
    max: RATE_LIMIT.MAX_REQUESTS, // Default limit: 100 requests per window
    standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
    legacyHeaders: false, // Don't use the `X-RateLimit-*` headers
    message: {
      success: false,
      message: 'Too many requests, please try again later.'
    },
    // Customize rate limit based on request properties
    keyGenerator: (req) => {
      // Use IP address as default key
      return req.ip;
    }
  };

  return rateLimit({
    ...defaultOptions,
    ...options
  });
};

// Global API rate limiter - applied to all routes
const globalLimiter = createRateLimiter();

// Auth route limiter - more strict for security
const authLimiter = createRateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20, // 20 requests per 15 minutes
  message: {
    success: false,
    message: 'Too many authentication attempts, please try again later.'
  }
});

// Strict limiter - for sensitive operations
const strictLimiter = createRateLimiter({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5, // 5 requests per hour
  message: {
    success: false,
    message: 'Too many sensitive operation attempts, please try again later.'
  }
});

// API limiter - for regular API endpoints
const apiLimiter = createRateLimiter({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 200 // 200 requests per 10 minutes
});

// User-specific rate limiter - rate limit based on authenticated user
const userLimiter = createRateLimiter({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 300, // 300 requests per 10 minutes
  // Use user ID as key if available, otherwise IP address
  keyGenerator: (req) => {
    return req.user ? `user_${req.user.userId}` : req.ip;
  }
});

module.exports = {
  createRateLimiter,
  globalLimiter,
  authLimiter,
  strictLimiter,
  apiLimiter,
  userLimiter
};
