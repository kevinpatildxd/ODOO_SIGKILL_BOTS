const db = require('../config/database');

class Tag {
  /**
   * Create a new tag
   * @param {Object} tagData - Tag data
   * @param {string} tagData.name - Tag name
   * @param {string} [tagData.description] - Tag description
   * @param {string} [tagData.color] - Tag color (hex code)
   * @returns {Promise<Object>} Created tag object
   */
  async create(tagData) {
    const { name, description, color } = tagData;
    
    try {
      const result = await db.query(
        `INSERT INTO tags (name, description, color)
         VALUES ($1, $2, $3)
         RETURNING id, name, description, color, usage_count, created_at`,
        [name.toLowerCase(), description || null, color || '#2196F3']
      );
      
      return result.rows[0];
    } catch (error) {
      if (error.code === '23505') { // Duplicate key error
        throw new Error('Tag already exists');
      }
      throw new Error(`Failed to create tag: ${error.message}`);
    }
  }

  /**
   * Get tag by ID
   * @param {number} id - Tag ID
   * @returns {Promise<Object|null>} Tag object or null if not found
   */
  async getById(id) {
    try {
      const result = await db.query(
        `SELECT id, name, description, color, usage_count, created_at
         FROM tags
         WHERE id = $1`,
        [id]
      );
      
      return result.rows[0] || null;
    } catch (error) {
      throw new Error(`Failed to get tag by ID: ${error.message}`);
    }
  }

  /**
   * Get tag by name
   * @param {string} name - Tag name
   * @returns {Promise<Object|null>} Tag object or null if not found
   */
  async getByName(name) {
    try {
      const result = await db.query(
        `SELECT id, name, description, color, usage_count, created_at
         FROM tags
         WHERE name = $1`,
        [name.toLowerCase()]
      );
      
      return result.rows[0] || null;
    } catch (error) {
      throw new Error(`Failed to get tag by name: ${error.message}`);
    }
  }

  /**
   * Update tag
   * @param {number} id - Tag ID
   * @param {Object} tagData - Tag data to update
   * @param {string} [tagData.name] - Tag name
   * @param {string} [tagData.description] - Tag description
   * @param {string} [tagData.color] - Tag color (hex code)
   * @returns {Promise<Object>} Updated tag object
   */
  async update(id, tagData) {
    const { name, description, color } = tagData;
    
    try {
      // Create dynamic query
      let query = 'UPDATE tags SET ';
      const values = [];
      const setClauses = [];
      let paramIndex = 1;
      
      if (name) {
        setClauses.push(`name = $${paramIndex}`);
        values.push(name.toLowerCase());
        paramIndex++;
      }
      
      if (description !== undefined) {
        setClauses.push(`description = $${paramIndex}`);
        values.push(description);
        paramIndex++;
      }
      
      if (color) {
        setClauses.push(`color = $${paramIndex}`);
        values.push(color);
        paramIndex++;
      }
      
      if (setClauses.length === 0) {
        throw new Error('No tag properties to update');
      }
      
      // Combine set clauses and add WHERE and RETURNING
      query += setClauses.join(', ');
      query += ` WHERE id = $${paramIndex} RETURNING id, name, description, color, usage_count, created_at`;
      values.push(id);
      
      const result = await db.query(query, values);
      
      if (result.rows.length === 0) {
        throw new Error('Tag not found');
      }
      
      return result.rows[0];
    } catch (error) {
      if (error.code === '23505') { // Duplicate key error
        throw new Error('Tag name already exists');
      }
      throw new Error(`Failed to update tag: ${error.message}`);
    }
  }

  /**
   * Delete tag
   * @param {number} id - Tag ID
   * @returns {Promise<boolean>} True if tag was deleted
   */
  async delete(id) {
    try {
      const result = await db.query(
        'DELETE FROM tags WHERE id = $1 RETURNING id',
        [id]
      );
      
      if (result.rows.length === 0) {
        throw new Error('Tag not found');
      }
      
      return true;
    } catch (error) {
      throw new Error(`Failed to delete tag: ${error.message}`);
    }
  }

  /**
   * Get all tags with pagination and optional search
   * @param {Object} options - Search options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=50] - Number of tags per page
   * @param {string} [options.search] - Search term
   * @param {string} [options.sort='usage'] - Sort by ('usage', 'name', 'newest')
   * @returns {Promise<Object>} Paginated tags
   */
  async getTags({ page = 1, limit = 50, search = '', sort = 'usage' }) {
    try {
      const offset = (page - 1) * limit;
      
      // Base query with parameters array
      let query = `
        SELECT id, name, description, color, usage_count, created_at
        FROM tags
        WHERE 1=1
      `;
      const queryParams = [];
      let paramIndex = 1;
      
      // Add search condition
      if (search) {
        query += ` AND (name ILIKE $${paramIndex} OR description ILIKE $${paramIndex})`;
        queryParams.push(`%${search}%`);
        paramIndex++;
      }
      
      // Add sorting
      switch (sort) {
        case 'name':
          query += ' ORDER BY name ASC';
          break;
        case 'newest':
          query += ' ORDER BY created_at DESC';
          break;
        case 'usage':
        default:
          query += ' ORDER BY usage_count DESC, name ASC';
      }
      
      // Add pagination
      query += ` LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
      queryParams.push(limit, offset);
      
      const result = await db.query(query, queryParams);
      
      // Count total tags matching the criteria (without pagination)
      let countQuery = 'SELECT COUNT(*) as total FROM tags WHERE 1=1';
      const countParams = [];
      
      if (search) {
        countQuery += ' AND (name ILIKE $1 OR description ILIKE $1)';
        countParams.push(`%${search}%`);
      }
      
      const countResult = await db.query(countQuery, countParams);
      const total = parseInt(countResult.rows[0].total);
      
      return {
        tags: result.rows,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      throw new Error(`Failed to get tags: ${error.message}`);
    }
  }

  /**
   * Add tags to a question
   * @param {number} questionId - Question ID
   * @param {Array<string>} tagNames - Array of tag names
   * @returns {Promise<Array>} Array of associated tags
   */
  async addTagsToQuestion(questionId, tagNames) {
    if (!tagNames || tagNames.length === 0) {
      return [];
    }
    
    try {
      const client = await db.getClient();
      
      try {
        await client.query('BEGIN');
        
        // Process each tag name
        const processedTags = [];
        
        for (const name of tagNames) {
          const normalizedName = name.toLowerCase().trim();
          
          if (!normalizedName) continue;
          
          // Find existing tag or create a new one
          let tag = await this.getByName(normalizedName);
          
          if (!tag) {
            // Create the tag if it doesn't exist
            tag = await this.create({ name: normalizedName });
          }
          
          // Add relation if it doesn't exist
          const relationCheck = await client.query(
            'SELECT 1 FROM question_tags WHERE question_id = $1 AND tag_id = $2',
            [questionId, tag.id]
          );
          
          if (relationCheck.rows.length === 0) {
            await client.query(
              'INSERT INTO question_tags (question_id, tag_id) VALUES ($1, $2)',
              [questionId, tag.id]
            );
            
            // Increment the usage count
            await client.query(
              'UPDATE tags SET usage_count = usage_count + 1 WHERE id = $1',
              [tag.id]
            );
          }
          
          processedTags.push(tag);
        }
        
        await client.query('COMMIT');
        
        return processedTags;
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    } catch (error) {
      throw new Error(`Failed to add tags to question: ${error.message}`);
    }
  }

  /**
   * Remove a tag from a question
   * @param {number} questionId - Question ID
   * @param {number} tagId - Tag ID
   * @returns {Promise<boolean>} True if tag was removed
   */
  async removeTagFromQuestion(questionId, tagId) {
    try {
      const client = await db.getClient();
      
      try {
        await client.query('BEGIN');
        
        // Check if relation exists
        const relation = await client.query(
          'DELETE FROM question_tags WHERE question_id = $1 AND tag_id = $2 RETURNING tag_id',
          [questionId, tagId]
        );
        
        if (relation.rows.length === 0) {
          throw new Error('Tag not associated with this question');
        }
        
        // Decrement the usage count
        await client.query(
          'UPDATE tags SET usage_count = GREATEST(0, usage_count - 1) WHERE id = $1',
          [tagId]
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
      throw new Error(`Failed to remove tag from question: ${error.message}`);
    }
  }

  /**
   * Get tags for a question
   * @param {number} questionId - Question ID
   * @returns {Promise<Array>} Array of tags
   */
  async getTagsForQuestion(questionId) {
    try {
      const result = await db.query(
        `SELECT t.id, t.name, t.description, t.color, t.usage_count, t.created_at
         FROM tags t
         JOIN question_tags qt ON t.id = qt.tag_id
         WHERE qt.question_id = $1
         ORDER BY t.name`,
        [questionId]
      );
      
      return result.rows;
    } catch (error) {
      throw new Error(`Failed to get tags for question: ${error.message}`);
    }
  }

  /**
   * Get popular tags with counts
   * @param {number} [limit=20] - Maximum number of tags to return
   * @returns {Promise<Array>} Array of tags with counts
   */
  async getPopularTags(limit = 20) {
    try {
      const result = await db.query(
        `SELECT id, name, description, color, usage_count, created_at
         FROM tags
         ORDER BY usage_count DESC, name
         LIMIT $1`,
        [limit]
      );
      
      return result.rows;
    } catch (error) {
      throw new Error(`Failed to get popular tags: ${error.message}`);
    }
  }
}

module.exports = new Tag();
