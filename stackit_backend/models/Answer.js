const db = require('../config/database');

class Answer {
  /**
   * Create a new answer
   * @param {Object} answerData - Answer data
   * @param {string} answerData.content - Answer content
   * @param {number} answerData.question_id - Question ID
   * @param {number} answerData.user_id - User ID
   * @returns {Promise<Object>} Created answer object
   */
  async create(answerData) {
    const { content, question_id, user_id } = answerData;
    
    try {
      // Start a transaction
      const client = await db.getClient();
      
      try {
        await client.query('BEGIN');
        
        // Insert the answer
        const answerResult = await client.query(
          `INSERT INTO answers (content, question_id, user_id)
           VALUES ($1, $2, $3)
           RETURNING id, content, question_id, user_id, is_accepted, vote_count, created_at, updated_at`,
          [content, question_id, user_id]
        );
        
        // Update the question's answer count
        await client.query(
          'UPDATE questions SET answer_count = answer_count + 1 WHERE id = $1',
          [question_id]
        );
        
        await client.query('COMMIT');
        
        return answerResult.rows[0];
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    } catch (error) {
      throw new Error(`Failed to create answer: ${error.message}`);
    }
  }

  /**
   * Get answer by ID
   * @param {number} id - Answer ID
   * @returns {Promise<Object|null>} Answer object or null if not found
   */
  async getById(id) {
    try {
      const result = await db.query(
        `SELECT a.*, u.username, u.avatar_url
         FROM answers a
         LEFT JOIN users u ON a.user_id = u.id
         WHERE a.id = $1`,
        [id]
      );
      
      return result.rows[0] || null;
    } catch (error) {
      throw new Error(`Failed to get answer by ID: ${error.message}`);
    }
  }

  /**
   * Update answer
   * @param {number} id - Answer ID
   * @param {Object} answerData - Answer data to update
   * @param {string} [answerData.content] - Answer content
   * @returns {Promise<Object>} Updated answer object
   */
  async update(id, answerData) {
    const { content } = answerData;
    
    try {
      // Create dynamic query
      let query = 'UPDATE answers SET updated_at = NOW()';
      const values = [];
      let paramIndex = 1;
      
      if (content) {
        query += `, content = $${paramIndex}`;
        values.push(content);
        paramIndex++;
      }
      
      // Add WHERE clause and RETURNING
      query += ` WHERE id = $${paramIndex} RETURNING id, content, question_id, user_id, is_accepted, vote_count, created_at, updated_at`;
      values.push(id);
      
      const result = await db.query(query, values);
      
      if (result.rows.length === 0) {
        throw new Error('Answer not found');
      }
      
      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to update answer: ${error.message}`);
    }
  }

  /**
   * Delete answer
   * @param {number} id - Answer ID
   * @returns {Promise<boolean>} True if answer was deleted
   */
  async delete(id) {
    try {
      // Start a transaction
      const client = await db.getClient();
      
      try {
        await client.query('BEGIN');
        
        // Get the answer to find its question ID
        const answerResult = await client.query(
          'SELECT question_id FROM answers WHERE id = $1',
          [id]
        );
        
        if (answerResult.rows.length === 0) {
          throw new Error('Answer not found');
        }
        
        const questionId = answerResult.rows[0].question_id;
        
        // Delete the answer
        await client.query('DELETE FROM answers WHERE id = $1', [id]);
        
        // Update the question's answer count
        await client.query(
          'UPDATE questions SET answer_count = answer_count - 1 WHERE id = $1',
          [questionId]
        );
        
        // If this was the accepted answer, remove the accepted_answer_id from the question
        await client.query(
          'UPDATE questions SET accepted_answer_id = NULL WHERE accepted_answer_id = $1',
          [id]
        );
        
        await client.query('COMMIT');
        
        return true;
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    } catch (error) {
      throw new Error(`Failed to delete answer: ${error.message}`);
    }
  }

  /**
   * Mark an answer as accepted
   * @param {number} id - Answer ID
   * @returns {Promise<Object>} Updated answer object
   */
  async markAsAccepted(id) {
    try {
      // Start a transaction
      const client = await db.getClient();
      
      try {
        await client.query('BEGIN');
        
        // Get the answer to find its question ID
        const answerResult = await client.query(
          'SELECT question_id FROM answers WHERE id = $1',
          [id]
        );
        
        if (answerResult.rows.length === 0) {
          throw new Error('Answer not found');
        }
        
        const questionId = answerResult.rows[0].question_id;
        
        // Remove the accepted status from any previously accepted answers for this question
        await client.query(
          'UPDATE answers SET is_accepted = FALSE WHERE question_id = $1 AND is_accepted = TRUE',
          [questionId]
        );
        
        // Mark this answer as accepted
        const result = await client.query(
          `UPDATE answers SET is_accepted = TRUE WHERE id = $1
           RETURNING id, content, question_id, user_id, is_accepted, vote_count, created_at, updated_at`,
          [id]
        );
        
        // Update the question with the accepted answer ID
        await client.query(
          'UPDATE questions SET accepted_answer_id = $1 WHERE id = $2',
          [id, questionId]
        );
        
        await client.query('COMMIT');
        
        return result.rows[0];
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    } catch (error) {
      throw new Error(`Failed to mark answer as accepted: ${error.message}`);
    }
  }

  /**
   * Remove accepted status from an answer
   * @param {number} id - Answer ID
   * @returns {Promise<Object>} Updated answer object
   */
  async unmarkAsAccepted(id) {
    try {
      // Start a transaction
      const client = await db.getClient();
      
      try {
        await client.query('BEGIN');
        
        // Get the answer to find its question ID
        const answerResult = await client.query(
          'SELECT question_id FROM answers WHERE id = $1',
          [id]
        );
        
        if (answerResult.rows.length === 0) {
          throw new Error('Answer not found');
        }
        
        const questionId = answerResult.rows[0].question_id;
        
        // Mark this answer as not accepted
        const result = await client.query(
          `UPDATE answers SET is_accepted = FALSE WHERE id = $1
           RETURNING id, content, question_id, user_id, is_accepted, vote_count, created_at, updated_at`,
          [id]
        );
        
        // Remove the accepted answer ID from the question
        await client.query(
          'UPDATE questions SET accepted_answer_id = NULL WHERE id = $1 AND accepted_answer_id = $2',
          [questionId, id]
        );
        
        await client.query('COMMIT');
        
        return result.rows[0];
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    } catch (error) {
      throw new Error(`Failed to remove accepted status from answer: ${error.message}`);
    }
  }

  /**
   * Update vote count
   * @param {number} id - Answer ID
   * @param {number} voteChange - Vote change (positive or negative)
   * @returns {Promise<number>} New vote count
   */
  async updateVoteCount(id, voteChange) {
    try {
      const result = await db.query(
        'UPDATE answers SET vote_count = vote_count + $1 WHERE id = $2 RETURNING vote_count',
        [voteChange, id]
      );
      
      if (result.rows.length === 0) {
        throw new Error('Answer not found');
      }
      
      return result.rows[0].vote_count;
    } catch (error) {
      throw new Error(`Failed to update vote count: ${error.message}`);
    }
  }

  /**
   * Get answers for a question with pagination
   * @param {number} questionId - Question ID
   * @param {Object} options - Pagination options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=10] - Number of answers per page
   * @param {string} [options.sort='votes'] - Sort by ('votes', 'newest', 'oldest')
   * @returns {Promise<Object>} Paginated answers
   */
  async getAnswersByQuestion(questionId, { page = 1, limit = 10, sort = 'votes' }) {
    try {
      const offset = (page - 1) * limit;
      
      let orderBy;
      switch (sort) {
        case 'newest':
          orderBy = 'a.created_at DESC';
          break;
        case 'oldest':
          orderBy = 'a.created_at ASC';
          break;
        case 'votes':
        default:
          orderBy = 'a.is_accepted DESC, a.vote_count DESC, a.created_at ASC';
      }
      
      const answersQuery = await db.query(
        `SELECT a.*, u.username, u.avatar_url
         FROM answers a
         LEFT JOIN users u ON a.user_id = u.id
         WHERE a.question_id = $1
         ORDER BY ${orderBy}
         LIMIT $2 OFFSET $3`,
        [questionId, limit, offset]
      );
      
      const countQuery = await db.query(
        'SELECT COUNT(*) as total FROM answers WHERE question_id = $1',
        [questionId]
      );
      
      const total = parseInt(countQuery.rows[0].total);
      
      return {
        answers: answersQuery.rows,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      throw new Error(`Failed to get answers for question: ${error.message}`);
    }
  }

  /**
   * Get answers by a user with pagination
   * @param {number} userId - User ID
   * @param {Object} options - Pagination options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=10] - Number of answers per page
   * @returns {Promise<Object>} Paginated answers
   */
  async getAnswersByUser(userId, { page = 1, limit = 10 }) {
    try {
      const offset = (page - 1) * limit;
      
      const answersQuery = await db.query(
        `SELECT a.*, q.title as question_title, q.slug as question_slug
         FROM answers a
         JOIN questions q ON a.question_id = q.id
         WHERE a.user_id = $1
         ORDER BY a.created_at DESC
         LIMIT $2 OFFSET $3`,
        [userId, limit, offset]
      );
      
      const countQuery = await db.query(
        'SELECT COUNT(*) as total FROM answers WHERE user_id = $1',
        [userId]
      );
      
      const total = parseInt(countQuery.rows[0].total);
      
      return {
        answers: answersQuery.rows,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      throw new Error(`Failed to get answers by user: ${error.message}`);
    }
  }
}

module.exports = new Answer();
