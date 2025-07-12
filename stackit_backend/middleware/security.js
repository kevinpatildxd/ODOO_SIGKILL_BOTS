/**
 * Security middleware functions
 */
const validator = require('validator');
const helmet = require('helmet');
const xss = require('xss-clean');
const hpp = require('hpp');
const { sanitizeInput } = require('../utils/helpers');

/**
 * Middleware to sanitize request bodies
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const sanitizeRequestData = (req, res, next) => {
  // Sanitize request body
  if (req.body && typeof req.body === 'object') {
    for (const key in req.body) {
      if (Object.prototype.hasOwnProperty.call(req.body, key)) {
        if (typeof req.body[key] === 'string') {
          req.body[key] = sanitizeInput(req.body[key]);
        }
      }
    }
  }

  // Sanitize request params
  if (req.params && typeof req.params === 'object') {
    for (const key in req.params) {
      if (Object.prototype.hasOwnProperty.call(req.params, key)) {
        if (typeof req.params[key] === 'string') {
          req.params[key] = sanitizeInput(req.params[key]);
        }
      }
    }
  }

  // Sanitize request query
  if (req.query && typeof req.query === 'object') {
    for (const key in req.query) {
      if (Object.prototype.hasOwnProperty.call(req.query, key)) {
        if (typeof req.query[key] === 'string') {
          req.query[key] = sanitizeInput(req.query[key]);
        }
      }
    }
  }

  next();
};

/**
 * Add security-related response headers
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const securityHeaders = (req, res, next) => {
  // Cache control
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('Expires', '0');
  res.setHeader('Surrogate-Control', 'no-store');

  next();
};

/**
 * Prevent clickjacking attacks
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const preventClickjacking = (req, res, next) => {
  res.setHeader('X-Frame-Options', 'DENY');
  next();
};

/**
 * Validate content type to prevent JSON/XML/CSRF attacks
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const validateContentType = (req, res, next) => {
  const method = req.method;
  if (
    (method === 'POST' || method === 'PUT' || method === 'PATCH') &&
    req.headers['content-type'] &&
    !req.headers['content-type'].includes('application/json')
  ) {
    return res.status(415).json({
      success: false,
      message: 'Unsupported Media Type - API only accepts application/json'
    });
  }
  next();
};

/**
 * Create default middleware stack for security
 * @returns {Array} Array of middleware functions
 */
const createSecurityMiddleware = () => {
  return [
    helmet(), // Basic security headers
    xss(), // Sanitize user input
    hpp(), // Protect against HTTP Parameter Pollution
    sanitizeRequestData, // Custom sanitization
    securityHeaders, // Additional security headers
    preventClickjacking, // Prevent clickjacking
    validateContentType // Validate content type
  ];
};

module.exports = {
  sanitizeRequestData,
  securityHeaders,
  preventClickjacking,
  validateContentType,
  createSecurityMiddleware
}; 