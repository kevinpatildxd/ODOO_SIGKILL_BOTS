/**
 * Controller for handling notification-related routes
 * @module controllers/notificationController
 */

const notificationService = require('../services/notificationService');

/**
 * Get all notifications for the authenticated user with pagination
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const getNotifications = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 10, unreadOnly = false } = req.query;
    
    const result = await notificationService.getNotificationsForUser(userId, {
      page: parseInt(page),
      limit: parseInt(limit),
      unreadOnly: unreadOnly === 'true'
    });
    
    res.status(200).json({
      success: true,
      data: result,
      message: 'Notifications retrieved successfully'
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get a single notification by ID
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const getNotificationById = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const notificationId = parseInt(req.params.id);
    
    const notification = await notificationService.getNotificationById(notificationId, userId);
    
    res.status(200).json({
      success: true,
      data: notification,
      message: 'Notification retrieved successfully'
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Mark a notification as read
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const markAsRead = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const notificationId = parseInt(req.params.id);
    
    await notificationService.markAsRead(notificationId, userId);
    
    res.status(200).json({
      success: true,
      message: 'Notification marked as read'
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Mark all notifications as read for the authenticated user
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const markAllAsRead = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    const markedCount = await notificationService.markAllAsRead(userId);
    
    res.status(200).json({
      success: true,
      data: { markedCount },
      message: `${markedCount} notifications marked as read`
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete a notification
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const deleteNotification = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const notificationId = parseInt(req.params.id);
    
    await notificationService.deleteNotification(notificationId, userId);
    
    res.status(200).json({
      success: true,
      message: 'Notification deleted successfully'
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete all notifications for the authenticated user
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const deleteAllNotifications = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    const deletedCount = await notificationService.deleteAllNotifications(userId);
    
    res.status(200).json({
      success: true,
      data: { deletedCount },
      message: `${deletedCount} notifications deleted`
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get the count of unread notifications for the authenticated user
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const getUnreadCount = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    const count = await notificationService.countUnreadNotifications(userId);
    
    res.status(200).json({
      success: true,
      data: { count },
      message: 'Unread notification count retrieved successfully'
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getNotifications,
  getNotificationById,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  deleteAllNotifications,
  getUnreadCount
};
