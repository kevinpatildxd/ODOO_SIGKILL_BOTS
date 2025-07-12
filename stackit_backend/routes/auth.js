const express = require('express');
const router = express.Router();

// Controllers
const authController = require('../controllers/authController');

// Middleware
const { authenticate } = require('../middleware/auth');
const { authLimiter, strictLimiter } = require('../middleware/rateLimit');
const { validateUser } = require('../middleware/validation');

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post('/register', authLimiter, validateUser.register, authController.register);

/**
 * @route   POST /api/auth/login
 * @desc    Login a user
 * @access  Public
 */
router.post('/login', authLimiter, validateUser.login, authController.login);

/**
 * @route   POST /api/auth/logout
 * @desc    Logout a user (client-side implementation)
 * @access  Public
 */
router.post('/logout', authController.logout);

/**
 * @route   POST /api/auth/password-reset/request
 * @desc    Request password reset
 * @access  Public
 */
router.post('/password-reset/request', strictLimiter, validateUser.resetRequest, authController.requestPasswordReset);

/**
 * @route   POST /api/auth/password-reset
 * @desc    Reset password with token
 * @access  Public
 */
router.post('/password-reset', strictLimiter, validateUser.resetPassword, authController.resetPassword);

/**
 * @route   GET /api/auth/profile
 * @desc    Get authenticated user's profile
 * @access  Private
 */
router.get('/profile', authenticate, authController.getProfile);

/**
 * @route   PUT /api/auth/profile
 * @desc    Update authenticated user's profile
 * @access  Private
 */
router.put('/profile', authenticate, validateUser.updateProfile, authController.updateProfile);

/**
 * @route   PUT /api/auth/change-password
 * @desc    Change authenticated user's password
 * @access  Private
 */
router.put('/change-password', authenticate, strictLimiter, validateUser.changePassword, authController.changePassword);

/**
 * @route   DELETE /api/auth/delete-account
 * @desc    Delete authenticated user's account
 * @access  Private
 */
router.delete('/delete-account', authenticate, strictLimiter, authController.deleteAccount);

module.exports = router;
