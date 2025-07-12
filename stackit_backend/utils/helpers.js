/**
 * Helper utility functions
 */
const validator = require('validator');
const crypto = require('crypto');

/**
 * Sanitize user input to prevent XSS attacks
 * @param {String} input - String to sanitize
 * @returns {String} Sanitized string
 */
const sanitizeInput = (input) => {
  if (!input || typeof input !== 'string') {
    return input;
  }
  return validator.escape(input);
};

/**
 * Sanitize an object by escaping all string values
 * @param {Object} obj - Object to sanitize
 * @returns {Object} Sanitized object
 */
const sanitizeObject = (obj) => {
  if (!obj || typeof obj !== 'object') {
    return obj;
  }
  
  const sanitized = {};
  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      if (typeof obj[key] === 'string') {
        sanitized[key] = sanitizeInput(obj[key]);
      } else if (typeof obj[key] === 'object' && obj[key] !== null) {
        sanitized[key] = sanitizeObject(obj[key]);
      } else {
        sanitized[key] = obj[key];
      }
    }
  }
  return sanitized;
};

/**
 * Generate a random string
 * @param {Number} length - Length of the string
 * @returns {String} Random string
 */
const generateRandomString = (length = 32) => {
  return crypto.randomBytes(Math.ceil(length / 2))
    .toString('hex')
    .slice(0, length);
};

/**
 * Generate a slug from a string
 * @param {String} text - Text to convert to slug
 * @returns {String} Slug
 */
const generateSlug = (text) => {
  return text
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')     // Replace spaces with -
    .replace(/&/g, '-and-')   // Replace & with 'and'
    .replace(/[^\w\-]+/g, '') // Remove all non-word characters
    .replace(/\-\-+/g, '-');  // Replace multiple - with single -
};

/**
 * Format response object
 * @param {Boolean} success - Success status
 * @param {Object|Array} data - Response data
 * @param {String} message - Response message
 * @returns {Object} Formatted response
 */
const formatResponse = (success, data = null, message = '') => {
  return {
    success,
    data,
    message
  };
};

/**
 * Formats pagination data
 * @param {Array} data - Result array
 * @param {Number} totalCount - Total count of items
 * @param {Number} page - Current page number
 * @param {Number} limit - Items per page
 * @returns {Object} Paginated response
 */
const paginatedResponse = (data, totalCount, page, limit) => {
  const totalPages = Math.ceil(totalCount / limit);
  return {
    data,
    meta: {
      currentPage: page,
      itemsPerPage: limit,
      totalItems: totalCount,
      totalPages
    }
  };
};

/**
 * Filter out sensitive fields from object
 * @param {Object} obj - Object to filter
 * @param {Array} fields - Fields to remove
 * @returns {Object} Filtered object
 */
const filterSensitiveFields = (obj, fields = ['password', 'password_hash']) => {
  if (!obj || typeof obj !== 'object') {
    return obj;
  }
  
  const filtered = { ...obj };
  fields.forEach(field => {
    if (field in filtered) {
      delete filtered[field];
    }
  });
  
  return filtered;
};

/**
 * Compute ETag for caching
 * @param {Object|Array|String} data - Data to hash
 * @returns {String} ETag hash
 */
const computeETag = (data) => {
  const str = typeof data === 'string' ? data : JSON.stringify(data);
  return crypto.createHash('md5').update(str).digest('hex');
};

/**
 * Parse pagination parameters from request
 * @param {Object} req - Express request object
 * @param {Number} defaultLimit - Default limit value
 * @param {Number} maxLimit - Maximum allowed limit value
 * @returns {Object} Parsed pagination parameters
 */
const parsePaginationParams = (req, defaultLimit = 10, maxLimit = 50) => {
  const page = Math.max(1, parseInt(req.query.page, 10) || 1);
  let limit = parseInt(req.query.limit, 10) || defaultLimit;
  
  // Ensure limit doesn't exceed maximum
  limit = Math.min(limit, maxLimit);
  
  const offset = (page - 1) * limit;
  
  return { page, limit, offset };
};

module.exports = {
  sanitizeInput,
  sanitizeObject,
  generateRandomString,
  generateSlug,
  formatResponse,
  paginatedResponse,
  filterSensitiveFields,
  computeETag,
  parsePaginationParams
};
