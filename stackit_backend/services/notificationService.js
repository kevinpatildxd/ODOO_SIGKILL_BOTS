const Notification = require('../models/Notification');
const User = require('../models/User');

class NotificationService {
  /**
   * Create a new notification
   * @param {Object} notificationData - Notification data
   * @param {number} notificationData.user_id - User ID to notify
   * @param {string} notificationData.type - Notification type (e.g., 'vote', 'answer', 'comment', 'mention')
   * @param {string} notificationData.title - Notification title
   * @param {string} notificationData.message - Notification message
   * @param {string} [notificationData.reference_type] - Reference type
   * @param {number} [notificationData.reference_id] - Reference ID
   * @returns {Promise<Object>} Created notification
   */
  async createNotification(notificationData) {
    try {
      // Verify user exists
      const user = await User.getById(notificationData.user_id);
      if (!user) {
        throw new Error('User not found');
      }

      // Create notification
      const notification = await Notification.create(notificationData);
      return notification;
    } catch (error) {
      throw new Error(`Failed to create notification: ${error.message}`);
    }
  }

  /**
   * Get notification by ID
   * @param {number} id - Notification ID
   * @param {number} userId - User ID (for security check)
   * @returns {Promise<Object>} Notification object
   */
  async getNotificationById(id, userId) {
    try {
      const notification = await Notification.getById(id);
      
      if (!notification) {
        throw new Error('Notification not found');
      }

      // Check if notification belongs to the user
      if (notification.user_id !== userId) {
        throw new Error('You do not have permission to view this notification');
      }

      return notification;
    } catch (error) {
      throw new Error(`Failed to get notification: ${error.message}`);
    }
  }

  /**
   * Get notifications for a user with pagination
   * @param {number} userId - User ID
   * @param {Object} options - Pagination options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=10] - Number of notifications per page
   * @param {boolean} [options.unreadOnly=false] - Only return unread notifications
   * @returns {Promise<Object>} Paginated notifications
   */
  async getNotificationsForUser(userId, options = {}) {
    try {
      // Verify user exists
      const user = await User.getById(userId);
      if (!user) {
        throw new Error('User not found');
      }

      return await Notification.getNotificationsForUser(userId, options);
    } catch (error) {
      throw new Error(`Failed to get notifications: ${error.message}`);
    }
  }

  /**
   * Mark notification as read
   * @param {number} id - Notification ID
   * @param {number} userId - User ID (for security check)
   * @returns {Promise<boolean>} True if notification was marked as read
   */
  async markAsRead(id, userId) {
    try {
      const result = await Notification.markAsRead(id, userId);
      return result;
    } catch (error) {
      throw new Error(`Failed to mark notification as read: ${error.message}`);
    }
  }

  /**
   * Mark all notifications for a user as read
   * @param {number} userId - User ID
   * @returns {Promise<number>} Number of notifications marked as read
   */
  async markAllAsRead(userId) {
    try {
      // Verify user exists
      const user = await User.getById(userId);
      if (!user) {
        throw new Error('User not found');
      }

      return await Notification.markAllAsRead(userId);
    } catch (error) {
      throw new Error(`Failed to mark all notifications as read: ${error.message}`);
    }
  }

  /**
   * Delete a notification
   * @param {number} id - Notification ID
   * @param {number} userId - User ID (for security check)
   * @returns {Promise<boolean>} True if notification was deleted
   */
  async deleteNotification(id, userId) {
    try {
      const result = await Notification.delete(id, userId);
      return result;
    } catch (error) {
      throw new Error(`Failed to delete notification: ${error.message}`);
    }
  }

  /**
   * Delete all notifications for a user
   * @param {number} userId - User ID
   * @returns {Promise<number>} Number of notifications deleted
   */
  async deleteAllNotifications(userId) {
    try {
      // Verify user exists
      const user = await User.getById(userId);
      if (!user) {
        throw new Error('User not found');
      }

      return await Notification.deleteAllForUser(userId);
    } catch (error) {
      throw new Error(`Failed to delete all notifications: ${error.message}`);
    }
  }

  /**
   * Count unread notifications for a user
   * @param {number} userId - User ID
   * @returns {Promise<number>} Number of unread notifications
   */
  async countUnreadNotifications(userId) {
    try {
      // Verify user exists
      const user = await User.getById(userId);
      if (!user) {
        throw new Error('User not found');
      }

      return await Notification.countUnreadNotifications(userId);
    } catch (error) {
      throw new Error(`Failed to count unread notifications: ${error.message}`);
    }
  }

  /**
   * Create notifications for a new answer
   * @param {Object} answerData - Answer data
   * @param {number} answerData.answer_id - Answer ID
   * @param {number} answerData.question_id - Question ID
   * @param {number} answerData.answer_user_id - User ID who posted the answer
   * @param {string} answerData.question_title - Question title
   * @returns {Promise<Array>} Created notifications
   */
  async notifyNewAnswer(answerData) {
    try {
      return await Notification.notifyNewAnswer(answerData);
    } catch (error) {
      throw new Error(`Failed to create new answer notifications: ${error.message}`);
    }
  }

  /**
   * Create notifications for answer acceptance
   * @param {Object} acceptData - Accept data
   * @param {number} acceptData.answer_id - Answer ID
   * @param {number} acceptData.question_id - Question ID
   * @param {string} acceptData.question_title - Question title
   * @returns {Promise<Array>} Created notifications
   */
  async notifyAnswerAccepted(acceptData) {
    try {
      return await Notification.notifyAnswerAccepted(acceptData);
    } catch (error) {
      throw new Error(`Failed to create answer accepted notifications: ${error.message}`);
    }
  }

  /**
   * Create notifications for votes
   * @param {Object} voteData - Vote data
   * @param {string} voteData.target_type - Target type ('question' or 'answer')
   * @param {number} voteData.target_id - Target ID (question or answer ID)
   * @param {number} voteData.voter_id - Voter user ID
   * @param {number} voteData.vote_type - Vote type (1 for upvote, -1 for downvote)
   * @returns {Promise<Array>} Created notifications
   */
  async notifyVote(voteData) {
    try {
      return await Notification.notifyVote(voteData);
    } catch (error) {
      throw new Error(`Failed to create vote notifications: ${error.message}`);
    }
  }

  /**
   * Send a direct notification from system to user
   * @param {number} userId - User ID to notify
   * @param {string} title - Notification title
   * @param {string} message - Notification message
   * @returns {Promise<Object>} Created notification
   */
  async sendSystemNotification(userId, title, message) {
    try {
      // Verify user exists
      const user = await User.getById(userId);
      if (!user) {
        throw new Error('User not found');
      }

      return await Notification.create({
        user_id: userId,
        type: 'system',
        title,
        message
      });
    } catch (error) {
      throw new Error(`Failed to send system notification: ${error.message}`);
    }
  }

  /**
   * Send a bulk notification to multiple users
   * @param {Array<number>} userIds - Array of user IDs to notify
   * @param {string} title - Notification title
   * @param {string} message - Notification message
   * @param {string} [type='system'] - Notification type
   * @returns {Promise<Array>} Created notifications
   */
  async sendBulkNotifications(userIds, title, message, type = 'system') {
    try {
      const notifications = [];
      
      for (const userId of userIds) {
        try {
          // Verify user exists
          const user = await User.getById(userId);
          if (user) {
            const notification = await Notification.create({
              user_id: userId,
              type,
              title,
              message
            });
            
            notifications.push(notification);
          }
        } catch (error) {
          console.error(`Failed to send notification to user ${userId}: ${error.message}`);
          // Continue with next user even if this one fails
        }
      }
      
      return notifications;
    } catch (error) {
      throw new Error(`Failed to send bulk notifications: ${error.message}`);
    }
  }
}

module.exports = new NotificationService();
