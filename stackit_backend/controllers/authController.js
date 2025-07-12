const authService = require('../services/authService');
const { HTTP_STATUS } = require('../utils/constants');
const logger = require('../utils/logger');

/**
 * Authentication controller
 */
class AuthController {
  /**
   * Register a new user
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware
   */
  async register(req, res, next) {
    try {
      const userData = req.body;
      const user = await authService.register(userData);
      
      res.status(HTTP_STATUS.CREATED).json({
        success: true,
        data: { user },
        message: 'User registered successfully'
      });
    } catch (error) {
      logger.error('Registration error:', { error: error.message });
      next(error);
    }
  }

  /**
   * Login a user
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware
   */
  async login(req, res, next) {
    try {
      const credentials = req.body;
      const { token, user } = await authService.login(credentials);
      
      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: { token, user },
        message: 'Login successful'
      });
    } catch (error) {
      logger.error('Login error:', { error: error.message });
      next(error);
    }
  }

  /**
   * Logout a user (client-side implementation)
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async logout(req, res) {
    // JWT tokens are stateless, so logout is handled client-side
    // by removing the token from storage
    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Logout successful'
    });
  }

  /**
   * Get the authenticated user's profile
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware
   */
  async getProfile(req, res, next) {
    try {
      const userId = req.user.userId;
      const user = await authService.getProfile(userId);
      
      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: { user },
        message: 'Profile retrieved successfully'
      });
    } catch (error) {
      logger.error('Get profile error:', { error: error.message });
      next(error);
    }
  }

  /**
   * Update the authenticated user's profile
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware
   */
  async updateProfile(req, res, next) {
    try {
      const userId = req.user.userId;
      const userData = req.body;
      const user = await authService.updateProfile(userId, userData);
      
      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: { user },
        message: 'Profile updated successfully'
      });
    } catch (error) {
      logger.error('Update profile error:', { error: error.message });
      next(error);
    }
  }

  /**
   * Change user password
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware
   */
  async changePassword(req, res, next) {
    try {
      const userId = req.user.userId;
      const { oldPassword, newPassword } = req.body;
      
      await authService.changePassword(userId, oldPassword, newPassword);
      
      res.status(HTTP_STATUS.OK).json({
        success: true,
        message: 'Password changed successfully'
      });
    } catch (error) {
      logger.error('Change password error:', { error: error.message });
      next(error);
    }
  }

  /**
   * Request password reset
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware
   */
  async requestPasswordReset(req, res, next) {
    try {
      const { email } = req.body;
      const result = await authService.requestPasswordReset(email);
      
      res.status(HTTP_STATUS.OK).json({
        success: true,
        message: 'Password reset instructions sent',
        data: { 
          ...result,
          // In production, resetToken would not be returned to the client
          // It would be sent via email instead
          note: 'For development purposes only. In production, the token would be sent via email.'
        }
      });
    } catch (error) {
      logger.error('Password reset request error:', { error: error.message });
      next(error);
    }
  }

  /**
   * Reset password with token
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware
   */
  async resetPassword(req, res, next) {
    try {
      const { resetToken, newPassword } = req.body;
      await authService.resetPassword(resetToken, newPassword);
      
      res.status(HTTP_STATUS.OK).json({
        success: true,
        message: 'Password reset successful'
      });
    } catch (error) {
      logger.error('Password reset error:', { error: error.message });
      next(error);
    }
  }

  /**
   * Delete user account
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware
   */
  async deleteAccount(req, res, next) {
    try {
      const userId = req.user.userId;
      await authService.deleteAccount(userId);
      
      res.status(HTTP_STATUS.OK).json({
        success: true,
        message: 'Account deleted successfully'
      });
    } catch (error) {
      logger.error('Delete account error:', { error: error.message });
      next(error);
    }
  }
}

module.exports = new AuthController();
