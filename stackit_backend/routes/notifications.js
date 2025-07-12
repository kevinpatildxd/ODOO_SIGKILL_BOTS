/**
 * Express router for notification routes
 * @module routes/notifications
 */

const express = require('express');
const { authenticate } = require('../middleware/auth');
const { apiLimiter } = require('../middleware/rateLimit');
const notificationController = require('../controllers/notificationController');

const router = express.Router();

/**
 * @route GET /api/notifications
 * @description Get all notifications for authenticated user
 * @access Private
 */
router.get('/', authenticate, apiLimiter, notificationController.getNotifications);

/**
 * @route GET /api/notifications/count
 * @description Get count of unread notifications
 * @access Private
 */
router.get('/count', authenticate, apiLimiter, notificationController.getUnreadCount);

/**
 * @route GET /api/notifications/:id
 * @description Get notification by id
 * @access Private
 */
router.get('/:id', authenticate, apiLimiter, notificationController.getNotificationById);

/**
 * @route PUT /api/notifications/:id/read
 * @description Mark a notification as read
 * @access Private
 */
router.put('/:id/read', authenticate, apiLimiter, notificationController.markAsRead);

/**
 * @route PUT /api/notifications/read-all
 * @description Mark all notifications as read
 * @access Private
 */
router.put('/read-all', authenticate, apiLimiter, notificationController.markAllAsRead);

/**
 * @route DELETE /api/notifications/:id
 * @description Delete a notification
 * @access Private
 */
router.delete('/:id', authenticate, apiLimiter, notificationController.deleteNotification);

/**
 * @route DELETE /api/notifications
 * @description Delete all notifications
 * @access Private
 */
router.delete('/', authenticate, apiLimiter, notificationController.deleteAllNotifications);

module.exports = router;

