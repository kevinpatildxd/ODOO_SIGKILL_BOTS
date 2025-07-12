const db = require('../config/database');
const slugify = require('slugify');

class Question {
  /**
   * Create a new question
   * @param {Object} questionData - Question data
   * @param {string} questionData.title - Question title
   * @param {string} questionData.description - Question description
   * @param {number} questionData.user_id - User ID
   * @returns {Promise<Object>} Created question object
   */
  async create(questionData) {
    const { title, description, user_id } = questionData;
    
    try {
      // Generate a unique slug based on the title
      const baseSlug = slugify(title, { lower: true, strict: true });
      let slug = baseSlug;
      let slugExists = true;
      let counter = 1;
      
      // Keep checking and incrementing until we find a unique slug
      while (slugExists) {
        const slugCheck = await db.query(
          'SELECT id FROM questions WHERE slug = $1',
          [slug]
        );
        
        if (slugCheck.rows.length === 0) {
          slugExists = false;
        } else {
          slug = `${baseSlug}-${counter}`;
          counter++;
        }
      }
      
      const result = await db.query(
        `INSERT INTO questions (title, description, slug, user_id)
         VALUES ($1, $2, $3, $4)
         RETURNING id, title, description, slug, user_id, view_count, vote_count, 
                   answer_count, status, created_at, updated_at`,
        [title, description, slug, user_id]
      );
      
      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to create question: ${error.message}`);
    }
  }

  /**
   * Get question by ID
   * @param {number} id - Question ID
   * @returns {Promise<Object|null>} Question object or null if not found
   */
  async getById(id) {
    try {
      const result = await db.query(
        `SELECT q.*, u.username, u.avatar_url,
                (SELECT array_agg(t.name) FROM tags t
                 JOIN question_tags qt ON t.id = qt.tag_id
                 WHERE qt.question_id = q.id) as tags
         FROM questions q
         LEFT JOIN users u ON q.user_id = u.id
         WHERE q.id = $1`,
        [id]
      );
      
      if (result.rows.length === 0) {
        return null;
      }
      
      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to get question by ID: ${error.message}`);
    }
  }

  /**
   * Get question by slug
   * @param {string} slug - Question slug
   * @returns {Promise<Object|null>} Question object or null if not found
   */
  async getBySlug(slug) {
    try {
      const result = await db.query(
        `SELECT q.*, u.username, u.avatar_url,
                (SELECT array_agg(t.name) FROM tags t
                 JOIN question_tags qt ON t.id = qt.tag_id
                 WHERE qt.question_id = q.id) as tags
         FROM questions q
         LEFT JOIN users u ON q.user_id = u.id
         WHERE q.slug = $1`,
        [slug]
      );
      
      if (result.rows.length === 0) {
        return null;
      }
      
      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to get question by slug: ${error.message}`);
    }
  }

  /**
   * Update question
   * @param {number} id - Question ID
   * @param {Object} questionData - Question data to update
   * @param {string} [questionData.title] - Question title
   * @param {string} [questionData.description] - Question description
   * @param {string} [questionData.status] - Question status
   * @param {number} [questionData.accepted_answer_id] - Accepted answer ID
   * @returns {Promise<Object>} Updated question object
   */
  async update(id, questionData) {
    const { title, description, status, accepted_answer_id } = questionData;
    
    try {
      // Create dynamic query
      let query = 'UPDATE questions SET updated_at = NOW()';
      const values = [];
      let paramIndex = 1;
      
      if (title) {
        query += `, title = $${paramIndex}`;
        values.push(title);
        paramIndex++;
        
        // Update slug if title changes
        const baseSlug = slugify(title, { lower: true, strict: true });
        let slug = baseSlug;
        let slugExists = true;
        let counter = 1;
        
        // Keep checking and incrementing until we find a unique slug
        while (slugExists) {
          const slugCheck = await db.query(
            'SELECT id FROM questions WHERE slug = $1 AND id != $2',
            [slug, id]
          );
          
          if (slugCheck.rows.length === 0) {
            slugExists = false;
          } else {
            slug = `${baseSlug}-${counter}`;
            counter++;
          }
        }
        
        query += `, slug = $${paramIndex}`;
        values.push(slug);
        paramIndex++;
      }
      
      if (description) {
        query += `, description = $${paramIndex}`;
        values.push(description);
        paramIndex++;
      }
      
      if (status) {
        query += `, status = $${paramIndex}`;
        values.push(status);
        paramIndex++;
      }
      
      if (accepted_answer_id !== undefined) {
        query += `, accepted_answer_id = $${paramIndex}`;
        values.push(accepted_answer_id);
        paramIndex++;
      }
      
      // Add WHERE clause and RETURNING
      query += ` WHERE id = $${paramIndex} RETURNING id, title, description, slug, user_id, 
                accepted_answer_id, view_count, vote_count, answer_count, status, created_at, updated_at`;
      values.push(id);
      
      const result = await db.query(query, values);
      
      if (result.rows.length === 0) {
        throw new Error('Question not found');
      }
      
      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to update question: ${error.message}`);
    }
  }

  /**
   * Delete question
   * @param {number} id - Question ID
   * @returns {Promise<boolean>} True if question was deleted
   */
  async delete(id) {
    try {
      const result = await db.query(
        'DELETE FROM questions WHERE id = $1 RETURNING id',
        [id]
      );
      
      if (result.rows.length === 0) {
        throw new Error('Question not found');
      }
      
      return true;
    } catch (error) {
      throw new Error(`Failed to delete question: ${error.message}`);
    }
  }

  /**
   * Increment question view count
   * @param {number} id - Question ID
   * @returns {Promise<number>} New view count
   */
  async incrementViewCount(id) {
    try {
      const result = await db.query(
        'UPDATE questions SET view_count = view_count + 1 WHERE id = $1 RETURNING view_count',
        [id]
      );
      
      if (result.rows.length === 0) {
        throw new Error('Question not found');
      }
      
      return result.rows[0].view_count;
    } catch (error) {
      throw new Error(`Failed to increment view count: ${error.message}`);
    }
  }

  /**
   * Update vote count
   * @param {number} id - Question ID
   * @param {number} voteChange - Vote change (positive or negative)
   * @returns {Promise<number>} New vote count
   */
  async updateVoteCount(id, voteChange) {
    try {
      const result = await db.query(
        'UPDATE questions SET vote_count = vote_count + $1 WHERE id = $2 RETURNING vote_count',
        [voteChange, id]
      );
      
      if (result.rows.length === 0) {
        throw new Error('Question not found');
      }
      
      return result.rows[0].vote_count;
    } catch (error) {
      throw new Error(`Failed to update vote count: ${error.message}`);
    }
  }

  /**
   * Update answer count
   * @param {number} id - Question ID
   * @param {number} answerChange - Answer count change (positive or negative)
   * @returns {Promise<number>} New answer count
   */
  async updateAnswerCount(id, answerChange) {
    try {
      const result = await db.query(
        'UPDATE questions SET answer_count = answer_count + $1 WHERE id = $2 RETURNING answer_count',
        [answerChange, id]
      );
      
      if (result.rows.length === 0) {
        throw new Error('Question not found');
      }
      
      return result.rows[0].answer_count;
    } catch (error) {
      throw new Error(`Failed to update answer count: ${error.message}`);
    }
  }

  /**
   * Get questions with pagination, search, and filtering
   * @param {Object} options - Search options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=10] - Number of questions per page
   * @param {string} [options.search] - Search term
   * @param {Array<string>} [options.tags] - Array of tag names to filter by
   * @param {string} [options.sort='newest'] - Sort by ('newest', 'votes', 'answers', 'views')
   * @param {string} [options.user_id] - Filter by user ID
   * @returns {Promise<Object>} Paginated questions
   */
  async getQuestions({ page = 1, limit = 10, search = '', tags = [], sort = 'newest', user_id = null }) {
    try {
      const offset = (page - 1) * limit;
      
      // Base query with parameters array
      let queryParams = [];
      let paramIndex = 1;
      
      // Start building the query
      let query = `
        WITH question_tag_counts AS (
          SELECT qt.question_id, array_agg(t.name) as tags
          FROM question_tags qt
          JOIN tags t ON qt.tag_id = t.id
          GROUP BY qt.question_id
        )
        SELECT q.*, u.username, u.avatar_url, qtc.tags
        FROM questions q
        LEFT JOIN users u ON q.user_id = u.id
        LEFT JOIN question_tag_counts qtc ON q.id = qtc.question_id
        WHERE 1=1
      `;
      
      // Add search condition
      if (search) {
        query += ` AND (q.title ILIKE $${paramIndex} OR q.description ILIKE $${paramIndex})`;
        queryParams.push(`%${search}%`);
        paramIndex++;
      }
      
      // Filter by user
      if (user_id) {
        query += ` AND q.user_id = $${paramIndex}`;
        queryParams.push(user_id);
        paramIndex++;
      }
      
      // Add tag filtering if specified
      if (tags && tags.length > 0) {
        // Join to question_tags and tags tables
        query += `
          AND q.id IN (
            SELECT DISTINCT qt.question_id
            FROM question_tags qt
            JOIN tags t ON qt.tag_id = t.id
            WHERE t.name = ANY($${paramIndex})
          )
        `;
        queryParams.push(tags);
        paramIndex++;
      }
      
      // Add sorting
      switch (sort) {
        case 'votes':
          query += ' ORDER BY q.vote_count DESC, q.created_at DESC';
          break;
        case 'answers':
          query += ' ORDER BY q.answer_count DESC, q.created_at DESC';
          break;
        case 'views':
          query += ' ORDER BY q.view_count DESC, q.created_at DESC';
          break;
        case 'newest':
        default:
          query += ' ORDER BY q.created_at DESC';
      }
      
      // Add pagination
      query += ` LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
      queryParams.push(limit, offset);
      
      const result = await db.query(query, queryParams);
      
      // Count total questions matching the criteria (without pagination)
      let countQuery = `
        SELECT COUNT(DISTINCT q.id) as total
        FROM questions q
      `;
      
      // Add tag join if filtering by tags
      if (tags && tags.length > 0) {
        countQuery += `
          JOIN question_tags qt ON q.id = qt.question_id
          JOIN tags t ON qt.tag_id = t.id
        `;
      }
      
      countQuery += ' WHERE 1=1';
      
      // Re-add the search and filter conditions
      const countParams = [];
      let countParamIndex = 1;
      
      if (search) {
        countQuery += ` AND (q.title ILIKE $${countParamIndex} OR q.description ILIKE $${countParamIndex})`;
        countParams.push(`%${search}%`);
        countParamIndex++;
      }
      
      if (user_id) {
        countQuery += ` AND q.user_id = $${countParamIndex}`;
        countParams.push(user_id);
        countParamIndex++;
      }
      
      if (tags && tags.length > 0) {
        countQuery += ` AND t.name = ANY($${countParamIndex})`;
        countParams.push(tags);
      }
      
      const countResult = await db.query(countQuery, countParams);
      const total = parseInt(countResult.rows[0].total);
      
      return {
        questions: result.rows,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      throw new Error(`Failed to get questions: ${error.message}`);
    }
  }

  /**
   * Get questions by tag
   * @param {string} tag - Tag name
   * @param {Object} options - Pagination options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=10] - Number of questions per page
   * @returns {Promise<Object>} Paginated questions
   */
  async getQuestionsByTag(tag, { page = 1, limit = 10 }) {
    try {
      return await this.getQuestions({
        page,
        limit,
        tags: [tag]
      });
    } catch (error) {
      throw new Error(`Failed to get questions by tag: ${error.message}`);
    }
  }

  /**
   * Get questions by user
   * @param {number} userId - User ID
   * @param {Object} options - Pagination options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=10] - Number of questions per page
   * @returns {Promise<Object>} Paginated questions
   */
  async getQuestionsByUser(userId, { page = 1, limit = 10 }) {
    try {
      return await this.getQuestions({
        page,
        limit,
        user_id: userId
      });
    } catch (error) {
      throw new Error(`Failed to get questions by user: ${error.message}`);
    }
  }
}

module.exports = new Question();
