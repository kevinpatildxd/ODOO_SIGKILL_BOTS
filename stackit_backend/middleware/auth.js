/**
 * Authentication middleware for protecting routes
 */
const { verifyToken, extractTokenFromHeader } = require('../config/jwt');
const logger = require('../utils/logger');
const { HTTP_STATUS } = require('../utils/constants');

/**
 * Middleware to verify JWT token and set req.user
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const authenticate = async (req, res, next) => {
  try {
    // Extract token from header
    const token = extractTokenFromHeader(req);

    if (!token) {
      return res.status(HTTP_STATUS.UNAUTHORIZED).json({
        success: false,
        message: 'Authentication token is missing'
      });
    }

    // Verify token
    const decoded = verifyToken(token);

    // Set user data in request object
    req.user = {
      userId: decoded.userId,
      username: decoded.username,
      role: decoded.role
    };

    // Continue with request
    next();
  } catch (error) {
    logger.error('Authentication error:', { error: error.message });
    return res.status(HTTP_STATUS.UNAUTHORIZED).json({
      success: false,
      message: 'Invalid or expired token'
    });
  }
};

/**
 * Middleware to check if user has admin role
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const authorizeAdmin = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(HTTP_STATUS.FORBIDDEN).json({
      success: false,
      message: 'Requires admin privileges'
    });
  }
  next();
};

/**
 * Middleware to check if user has moderator or admin role
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const authorizeModerator = (req, res, next) => {
  if (!req.user || (req.user.role !== 'admin' && req.user.role !== 'moderator')) {
    return res.status(HTTP_STATUS.FORBIDDEN).json({
      success: false,
      message: 'Requires moderator privileges'
    });
  }
  next();
};

/**
 * Middleware to check if user is accessing their own resource or has admin privileges
 * @param {String} paramName - Name of the parameter containing the user ID (default: 'userId')
 * @returns {Function} Middleware function
 */
const authorizeOwner = (paramName = 'userId') => {
  return (req, res, next) => {
    const resourceUserId = parseInt(req.params[paramName], 10);
    
    if (
      !req.user || 
      (req.user.userId !== resourceUserId && req.user.role !== 'admin')
    ) {
      return res.status(HTTP_STATUS.FORBIDDEN).json({
        success: false,
        message: 'You are not authorized to perform this action'
      });
    }
    next();
  };
};

module.exports = {
  authenticate,
  authorizeAdmin,
  authorizeModerator,
  authorizeOwner
};
