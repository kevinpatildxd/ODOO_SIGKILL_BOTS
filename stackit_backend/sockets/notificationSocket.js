/**
 * Socket handlers for notification-related events
 * @module sockets/notificationSocket
 */

const notificationService = require('../services/notificationService');
const logger = require('../utils/logger');

/**
 * Attach notification-related socket event handlers to the Socket.io instance
 * @param {Object} io - Socket.io server instance
 */
function attachNotificationHandlers(io) {
  io.on('connection', (socket) => {
    // Handle notification status
    socket.on('get_notification_count', async () => {
      try {
        const count = await notificationService.countUnreadNotifications(socket.userId);
        socket.emit('notification_count', { count });
      } catch (error) {
        logger.error(`Error getting notification count: ${error.message}`);
        socket.emit('error', { message: 'Failed to get notification count' });
      }
    });

    // Handle marking a notification as read
    socket.on('mark_notification_read', async (notificationId) => {
      try {
        if (!notificationId) {
          return socket.emit('error', { message: 'Notification ID is required' });
        }

        await notificationService.markAsRead(notificationId, socket.userId);
        
        // Update the unread count
        const count = await notificationService.countUnreadNotifications(socket.userId);
        socket.emit('notification_count', { count });
        
        logger.info(`Notification ${notificationId} marked as read by user ${socket.userId}`);
      } catch (error) {
        logger.error(`Error marking notification as read: ${error.message}`);
        socket.emit('error', { message: 'Failed to mark notification as read' });
      }
    });

    // Handle marking all notifications as read
    socket.on('mark_all_notifications_read', async () => {
      try {
        const markedCount = await notificationService.markAllAsRead(socket.userId);
        
        socket.emit('notification_count', { count: 0 });
        socket.emit('all_notifications_marked_read', { markedCount });
        
        logger.info(`All notifications marked as read by user ${socket.userId}, count: ${markedCount}`);
      } catch (error) {
        logger.error(`Error marking all notifications as read: ${error.message}`);
        socket.emit('error', { message: 'Failed to mark all notifications as read' });
      }
    });

    // Handle notification sending (admin or system only)
    socket.on('send_notification', async (data) => {
      try {
        // Check if user has permission (would require role checking)
        // For now, assume only system can send direct notifications
        
        if (!data || !data.userId || !data.title || !data.message) {
          return socket.emit('error', { message: 'User ID, title, and message are required' });
        }

        // Create the notification
        const notification = await notificationService.createNotification({
          user_id: data.userId,
          type: data.type || 'system',
          title: data.title,
          message: data.message,
          reference_type: data.referenceType,
          reference_id: data.referenceId
        });

        // Emit to the targeted user's room
        io.to(`user_${data.userId}`).emit('notification', notification);
        
        logger.info(`Notification sent to user ${data.userId} by user ${socket.userId}`);
      } catch (error) {
        logger.error(`Error sending notification: ${error.message}`);
        socket.emit('error', { message: 'Failed to send notification' });
      }
    });
    
    // Listen for subscription to user's notification channel
    socket.on('subscribe_to_notifications', () => {
      const roomName = `user_${socket.userId}`;
      socket.join(roomName);
      logger.info(`User ${socket.userId} subscribed to their notifications`);
    });
    
    // Listen for unsubscription from notification channel
    socket.on('unsubscribe_from_notifications', () => {
      const roomName = `user_${socket.userId}`;
      socket.leave(roomName);
      logger.info(`User ${socket.userId} unsubscribed from their notifications`);
    });
  });
}

module.exports = attachNotificationHandlers;
