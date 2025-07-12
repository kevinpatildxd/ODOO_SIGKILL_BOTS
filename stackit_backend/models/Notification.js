const db = require('../config/database');

class Notification {
  /**
   * Create a new notification
   * @param {Object} notificationData - Notification data
   * @param {number} notificationData.user_id - User ID to notify
   * @param {string} notificationData.type - Notification type (e.g., 'vote', 'answer', 'comment', 'mention')
   * @param {string} notificationData.title - Notification title/summary
   * @param {string} notificationData.message - Notification detailed message
   * @param {string} [notificationData.reference_type] - Reference type (e.g., 'question', 'answer')
   * @param {number} [notificationData.reference_id] - Reference ID
   * @returns {Promise<Object>} Created notification object
   */
  async create(notificationData) {
    const { user_id, type, title, message, reference_type, reference_id } = notificationData;
    
    try {
      const result = await db.query(
        `INSERT INTO notifications (user_id, type, title, message, reference_type, reference_id)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING id, user_id, type, title, message, reference_type, reference_id, is_read, created_at`,
        [user_id, type, title, message, reference_type || null, reference_id || null]
      );
      
      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to create notification: ${error.message}`);
    }
  }

  /**
   * Get notification by ID
   * @param {number} id - Notification ID
   * @returns {Promise<Object|null>} Notification object or null if not found
   */
  async getById(id) {
    try {
      const result = await db.query(
        `SELECT id, user_id, type, title, message, reference_type, reference_id, is_read, created_at
         FROM notifications
         WHERE id = $1`,
        [id]
      );
      
      return result.rows[0] || null;
    } catch (error) {
      throw new Error(`Failed to get notification by ID: ${error.message}`);
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
  async getNotificationsForUser(userId, { page = 1, limit = 10, unreadOnly = false }) {
    try {
      const offset = (page - 1) * limit;
      
      let query = `
        SELECT id, user_id, type, title, message, reference_type, reference_id, is_read, created_at
        FROM notifications
        WHERE user_id = $1
      `;
      
      const queryParams = [userId];
      let paramIndex = 2;
      
      if (unreadOnly) {
        query += ` AND is_read = FALSE`;
      }
      
      query += ` ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
      queryParams.push(limit, offset);
      
      const result = await db.query(query, queryParams);
      
      // Get count of all matching notifications
      let countQuery = `
        SELECT COUNT(*) as total
        FROM notifications
        WHERE user_id = $1
      `;
      
      const countParams = [userId];
      
      if (unreadOnly) {
        countQuery += ` AND is_read = FALSE`;
      }
      
      const countResult = await db.query(countQuery, countParams);
      const total = parseInt(countResult.rows[0].total);
      
      return {
        notifications: result.rows,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      throw new Error(`Failed to get notifications for user: ${error.message}`);
    }
  }

  /**
   * Mark a notification as read
   * @param {number} id - Notification ID
   * @param {number} userId - User ID (for security check)
   * @returns {Promise<boolean>} True if notification was marked as read
   */
  async markAsRead(id, userId) {
    try {
      const result = await db.query(
        `UPDATE notifications SET is_read = TRUE
         WHERE id = $1 AND user_id = $2
         RETURNING id`,
        [id, userId]
      );
      
      if (result.rows.length === 0) {
        throw new Error('Notification not found or does not belong to this user');
      }
      
      return true;
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
      const result = await db.query(
        `UPDATE notifications SET is_read = TRUE
         WHERE user_id = $1 AND is_read = FALSE
         RETURNING id`,
        [userId]
      );
      
      return result.rows.length;
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
  async delete(id, userId) {
    try {
      const result = await db.query(
        `DELETE FROM notifications
         WHERE id = $1 AND user_id = $2
         RETURNING id`,
        [id, userId]
      );
      
      if (result.rows.length === 0) {
        throw new Error('Notification not found or does not belong to this user');
      }
      
      return true;
    } catch (error) {
      throw new Error(`Failed to delete notification: ${error.message}`);
    }
  }

  /**
   * Delete all notifications for a user
   * @param {number} userId - User ID
   * @returns {Promise<number>} Number of notifications deleted
   */
  async deleteAllForUser(userId) {
    try {
      const result = await db.query(
        `DELETE FROM notifications
         WHERE user_id = $1
         RETURNING id`,
        [userId]
      );
      
      return result.rows.length;
    } catch (error) {
      throw new Error(`Failed to delete all notifications for user: ${error.message}`);
    }
  }

  /**
   * Count unread notifications for a user
   * @param {number} userId - User ID
   * @returns {Promise<number>} Number of unread notifications
   */
  async countUnreadNotifications(userId) {
    try {
      const result = await db.query(
        `SELECT COUNT(*) as count
         FROM notifications
         WHERE user_id = $1 AND is_read = FALSE`,
        [userId]
      );
      
      return parseInt(result.rows[0].count);
    } catch (error) {
      throw new Error(`Failed to count unread notifications: ${error.message}`);
    }
  }

  /**
   * Create notifications for users interested in a question when an answer is posted
   * @param {Object} answerData - Answer data
   * @param {number} answerData.answer_id - Answer ID
   * @param {number} answerData.question_id - Question ID
   * @param {number} answerData.answer_user_id - User ID who posted the answer
   * @param {string} answerData.question_title - Question title
   * @returns {Promise<Array>} Created notifications
   */
  async notifyNewAnswer(answerData) {
    const { answer_id, question_id, answer_user_id, question_title } = answerData;
    
    try {
      // Get question author
      const questionAuthorQuery = await db.query(
        'SELECT user_id FROM questions WHERE id = $1',
        [question_id]
      );
      
      if (questionAuthorQuery.rows.length === 0) {
        throw new Error('Question not found');
      }
      
      const questionAuthorId = questionAuthorQuery.rows[0].user_id;
      
      // Don't notify if the answer author is the same as the question author
      if (questionAuthorId === answer_user_id) {
        return [];
      }
      
      // Create notification for question author
      const notification = await this.create({
        user_id: questionAuthorId,
        type: 'answer',
        title: 'New answer to your question',
        message: `Someone posted a new answer to your question: "${question_title}"`,
        reference_type: 'answer',
        reference_id: answer_id
      });
      
      return [notification];
    } catch (error) {
      throw new Error(`Failed to create new answer notifications: ${error.message}`);
    }
  }

  /**
   * Create notifications for answer author when their answer is accepted
   * @param {Object} acceptData - Accept data
   * @param {number} acceptData.answer_id - Answer ID
   * @param {number} acceptData.question_id - Question ID
   * @param {string} acceptData.question_title - Question title
   * @returns {Promise<Array>} Created notifications
   */
  async notifyAnswerAccepted(acceptData) {
    const { answer_id, question_id, question_title } = acceptData;
    
    try {
      // Get answer author
      const answerAuthorQuery = await db.query(
        'SELECT user_id FROM answers WHERE id = $1',
        [answer_id]
      );
      
      if (answerAuthorQuery.rows.length === 0) {
        throw new Error('Answer not found');
      }
      
      const answerAuthorId = answerAuthorQuery.rows[0].user_id;
      
      // Get question author
      const questionAuthorQuery = await db.query(
        'SELECT user_id FROM questions WHERE id = $1',
        [question_id]
      );
      
      if (questionAuthorQuery.rows.length === 0) {
        throw new Error('Question not found');
      }
      
      const questionAuthorId = questionAuthorQuery.rows[0].user_id;
      
      // Don't notify if the answer author is the same as the question author
      if (answerAuthorId === questionAuthorId) {
        return [];
      }
      
      // Create notification for answer author
      const notification = await this.create({
        user_id: answerAuthorId,
        type: 'accept',
        title: 'Your answer was accepted',
        message: `Your answer to the question "${question_title}" was accepted as the best answer.`,
        reference_type: 'question',
        reference_id: question_id
      });
      
      return [notification];
    } catch (error) {
      throw new Error(`Failed to create answer accepted notifications: ${error.message}`);
    }
  }

  /**
   * Create notifications for content author when their content receives a vote
   * @param {Object} voteData - Vote data
   * @param {string} voteData.target_type - Target type ('question' or 'answer')
   * @param {number} voteData.target_id - Target ID (question or answer ID)
   * @param {number} voteData.voter_id - Voter user ID
   * @param {number} voteData.vote_type - Vote type (1 for upvote, -1 for downvote)
   * @returns {Promise<Array>} Created notifications
   */
  async notifyVote(voteData) {
    const { target_type, target_id, voter_id, vote_type } = voteData;
    
    try {
      // Get content details and author
      let authorId, contentTitle, referenceId;
      
      if (target_type === 'question') {
        const questionQuery = await db.query(
          'SELECT user_id, title FROM questions WHERE id = $1',
          [target_id]
        );
        
        if (questionQuery.rows.length === 0) {
          throw new Error('Question not found');
        }
        
        authorId = questionQuery.rows[0].user_id;
        contentTitle = questionQuery.rows[0].title;
        referenceId = target_id;
      } else if (target_type === 'answer') {
        const answerQuery = await db.query(
          `SELECT a.user_id, q.id as question_id, q.title as question_title
           FROM answers a
           JOIN questions q ON a.question_id = q.id
           WHERE a.id = $1`,
          [target_id]
        );
        
        if (answerQuery.rows.length === 0) {
          throw new Error('Answer not found');
        }
        
        authorId = answerQuery.rows[0].user_id;
        contentTitle = answerQuery.rows[0].question_title;
        referenceId = answerQuery.rows[0].question_id;
      } else {
        throw new Error('Invalid target type');
      }
      
      // Don't notify if the voter is the same as the content author
      if (authorId === voter_id) {
        return [];
      }
      
      // Only notify for upvotes
      if (vote_type !== 1) {
        return [];
      }
      
      // Create notification for content author
      const notification = await this.create({
        user_id: authorId,
        type: 'vote',
        title: `Your ${target_type} was upvoted`,
        message: `Someone upvoted your ${target_type} on "${contentTitle}"`,
        reference_type: target_type === 'question' ? 'question' : 'answer',
        reference_id: target_type === 'question' ? referenceId : target_id
      });
      
      return [notification];
    } catch (error) {
      throw new Error(`Failed to create vote notifications: ${error.message}`);
    }
  }
}

module.exports = new Notification();
