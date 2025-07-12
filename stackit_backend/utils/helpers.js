/**
 * Helper utility functions for the application
 */

/**
 * Generate a URL-friendly slug from a string
 * @param {String} text - Text to convert to slug
 * @returns {String} URL-friendly slug
 */
const generateSlug = (text) => {
  return text
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-') // Replace spaces with -
    .replace(/&/g, '-and-') // Replace & with 'and'
    .replace(/[^\w\-]+/g, '') // Remove all non-word characters
    .replace(/\-\-+/g, '-') // Replace multiple - with single -
    .replace(/^-+/, '') // Trim - from start of text
    .replace(/-+$/, ''); // Trim - from end of text
};

/**
 * Format date to a readable string
 * @param {Date} date - Date to format
 * @returns {String} Formatted date string
 */
const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
};

/**
 * Paginate an array of items
 * @param {Array} items - Array of items to paginate
 * @param {Number} page - Current page number
 * @param {Number} limit - Number of items per page
 * @returns {Object} Paginated result object
 */
const paginate = (items, page = 1, limit = 10) => {
  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const total = items.length;
  
  const result = {
    data: items.slice(startIndex, endIndex),
    pagination: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
      hasNext: endIndex < total,
      hasPrev: startIndex > 0
    }
  };
  
  return result;
};

/**
 * Remove sensitive data from user object
 * @param {Object} user - User object
 * @returns {Object} Sanitized user object
 */
const sanitizeUser = (user) => {
  if (!user) return null;
  
  const { password_hash, ...sanitizedUser } = user;
  return sanitizedUser;
};

/**
 * Handle async/await errors in Express routes
 * @param {Function} fn - Async function to wrap
 * @returns {Function} Express middleware function
 */
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

/**
 * Generate a random string
 * @param {Number} length - Length of the string
 * @returns {String} Random string
 */
const generateRandomString = (length = 10) => {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  const charactersLength = characters.length;
  
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  
  return result;
};

module.exports = {
  generateSlug,
  formatDate,
  paginate,
  sanitizeUser,
  asyncHandler,
  generateRandomString
};
