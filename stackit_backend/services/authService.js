const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

class AuthService {
  /**
   * Register a new user
   * @param {Object} userData - User registration data
   * @param {string} userData.username - Username
   * @param {string} userData.email - Email address
   * @param {string} userData.password - Plain text password
   * @returns {Promise<Object>} Registered user data
   */
  async register(userData) {
    const { username, email, password } = userData;

    try {
      // Check if username already exists
      const existingUsername = await User.getByUsername(username);
      if (existingUsername) {
        throw new Error('Username is already taken');
      }

      // Check if email already exists
      const existingEmail = await User.getByEmail(email);
      if (existingEmail) {
        throw new Error('Email is already registered');
      }

      // Hash the password
      const salt = await bcrypt.genSalt(12);
      const password_hash = await bcrypt.hash(password, salt);

      // Create the user
      const user = await User.create({
        username,
        email,
        password_hash
      });

      // Remove password_hash from the return object
      const { password_hash: _, ...userWithoutPassword } = user;

      return userWithoutPassword;
    } catch (error) {
      throw new Error(`Registration failed: ${error.message}`);
    }
  }

  /**
   * Login a user
   * @param {Object} credentials - Login credentials
   * @param {string} credentials.email - Email address
   * @param {string} credentials.password - Plain text password
   * @returns {Promise<Object>} Login data with token and user info
   */
  async login(credentials) {
    const { email, password } = credentials;

    try {
      // Get user by email
      const user = await User.getByEmail(email);
      if (!user) {
        throw new Error('Invalid credentials');
      }

      // Compare passwords
      const isPasswordValid = await bcrypt.compare(password, user.password_hash);
      if (!isPasswordValid) {
        throw new Error('Invalid credentials');
      }

      // Generate JWT token
      const token = jwt.sign(
        { userId: user.id, role: user.role },
        process.env.JWT_SECRET || 'your-secret-key',
        { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
      );

      // Remove password_hash from the return object
      const { password_hash: _, ...userWithoutPassword } = user;

      return {
        token,
        user: userWithoutPassword
      };
    } catch (error) {
      throw new Error(`Login failed: ${error.message}`);
    }
  }

  /**
   * Get user profile by ID
   * @param {number} userId - User ID
   * @returns {Promise<Object>} User profile data
   */
  async getProfile(userId) {
    try {
      const user = await User.getById(userId);
      if (!user) {
        throw new Error('User not found');
      }

      return user;
    } catch (error) {
      throw new Error(`Failed to get user profile: ${error.message}`);
    }
  }

  /**
   * Update user profile
   * @param {number} userId - User ID
   * @param {Object} userData - User data to update
   * @returns {Promise<Object>} Updated user profile
   */
  async updateProfile(userId, userData) {
    try {
      // If username is being updated, check if it's unique
      if (userData.username) {
        const existingUsername = await User.getByUsername(userData.username);
        if (existingUsername && existingUsername.id !== userId) {
          throw new Error('Username is already taken');
        }
      }

      // If email is being updated, check if it's unique
      if (userData.email) {
        const existingEmail = await User.getByEmail(userData.email);
        if (existingEmail && existingEmail.id !== userId) {
          throw new Error('Email is already registered');
        }
      }

      // Update user profile
      const user = await User.update(userId, userData);
      return user;
    } catch (error) {
      throw new Error(`Failed to update profile: ${error.message}`);
    }
  }

  /**
   * Change user password
   * @param {number} userId - User ID
   * @param {string} oldPassword - Current password
   * @param {string} newPassword - New password
   * @returns {Promise<boolean>} True if password was changed
   */
  async changePassword(userId, oldPassword, newPassword) {
    try {
      // Get user data
      const user = await User.getById(userId);
      if (!user) {
        throw new Error('User not found');
      }

      // Verify old password
      const isPasswordValid = await bcrypt.compare(oldPassword, user.password_hash);
      if (!isPasswordValid) {
        throw new Error('Current password is incorrect');
      }

      // Hash new password
      const salt = await bcrypt.genSalt(12);
      const password_hash = await bcrypt.hash(newPassword, salt);

      // Update password
      const updated = await User.updatePassword(userId, password_hash);
      return updated;
    } catch (error) {
      throw new Error(`Failed to change password: ${error.message}`);
    }
  }

  /**
   * Verify JWT token
   * @param {string} token - JWT token
   * @returns {Promise<Object>} Decoded token payload
   */
  verifyToken(token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
      return decoded;
    } catch (error) {
      throw new Error('Invalid token');
    }
  }

  /**
   * Request password reset
   * @param {string} email - User email
   * @returns {Promise<Object>} Reset token data
   */
  async requestPasswordReset(email) {
    try {
      // Get user by email
      const user = await User.getByEmail(email);
      if (!user) {
        throw new Error('User not found');
      }

      // Generate reset token (expires in 1 hour)
      const resetToken = jwt.sign(
        { userId: user.id, purpose: 'password_reset' },
        process.env.JWT_SECRET || 'your-secret-key',
        { expiresIn: '1h' }
      );

      // In a real application, send an email with the reset link
      // For this project, we'll just return the token
      return {
        message: 'Password reset link sent to your email',
        resetToken // In production, this would be sent via email, not returned directly
      };
    } catch (error) {
      throw new Error(`Failed to request password reset: ${error.message}`);
    }
  }

  /**
   * Reset password using reset token
   * @param {string} resetToken - Password reset token
   * @param {string} newPassword - New password
   * @returns {Promise<boolean>} True if password was reset
   */
  async resetPassword(resetToken, newPassword) {
    try {
      // Verify reset token
      const decoded = jwt.verify(resetToken, process.env.JWT_SECRET || 'your-secret-key');
      
      // Check if token is for password reset
      if (decoded.purpose !== 'password_reset') {
        throw new Error('Invalid reset token');
      }

      // Hash new password
      const salt = await bcrypt.genSalt(12);
      const password_hash = await bcrypt.hash(newPassword, salt);

      // Update password
      const updated = await User.updatePassword(decoded.userId, password_hash);
      return updated;
    } catch (error) {
      throw new Error(`Failed to reset password: ${error.message}`);
    }
  }

  /**
   * Delete user account
   * @param {number} userId - User ID
   * @returns {Promise<boolean>} True if account was deleted
   */
  async deleteAccount(userId) {
    try {
      const deleted = await User.delete(userId);
      return deleted;
    } catch (error) {
      throw new Error(`Failed to delete account: ${error.message}`);
    }
  }
}

module.exports = new AuthService();
