const db = require('../config/database');

class User {
  /**
   * Create a new user
   * @param {Object} userData - User data
   * @param {string} userData.username - Username
   * @param {string} userData.email - Email address
   * @param {string} userData.password_hash - Hashed password
   * @param {string} [userData.avatar_url] - URL to user's avatar image
   * @param {string} [userData.bio] - User bio
   * @returns {Promise<Object>} Created user object
   */
  async create(userData) {
    const { username, email, password_hash, avatar_url, bio } = userData;
    
    try {
      const result = await db.query(
        `INSERT INTO users (username, email, password_hash, avatar_url, bio)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING id, username, email, avatar_url, bio, role, reputation, created_at, updated_at`,
        [username, email, password_hash, avatar_url || null, bio || null]
      );
      
      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to create user: ${error.message}`);
    }
  }

  /**
   * Get user by ID
   * @param {number} id - User ID
   * @returns {Promise<Object|null>} User object or null if not found
   */
  async getById(id) {
    try {
      const result = await db.query(
        `SELECT id, username, email, avatar_url, bio, role, reputation, created_at, updated_at
         FROM users
         WHERE id = $1`,
        [id]
      );
      
      return result.rows[0] || null;
    } catch (error) {
      throw new Error(`Failed to get user by ID: ${error.message}`);
    }
  }

  /**
   * Get user by email
   * @param {string} email - User email
   * @returns {Promise<Object|null>} User object or null if not found
   */
  async getByEmail(email) {
    try {
      const result = await db.query(
        `SELECT id, username, email, password_hash, avatar_url, bio, role, reputation, created_at, updated_at
         FROM users
         WHERE email = $1`,
        [email]
      );
      
      return result.rows[0] || null;
    } catch (error) {
      throw new Error(`Failed to get user by email: ${error.message}`);
    }
  }

  /**
   * Get user by username
   * @param {string} username - Username
   * @returns {Promise<Object|null>} User object or null if not found
   */
  async getByUsername(username) {
    try {
      const result = await db.query(
        `SELECT id, username, email, password_hash, avatar_url, bio, role, reputation, created_at, updated_at
         FROM users
         WHERE username = $1`,
        [username]
      );
      
      return result.rows[0] || null;
    } catch (error) {
      throw new Error(`Failed to get user by username: ${error.message}`);
    }
  }

  /**
   * Update user data
   * @param {number} id - User ID
   * @param {Object} userData - User data to update
   * @param {string} [userData.username] - Username
   * @param {string} [userData.email] - Email address
   * @param {string} [userData.avatar_url] - URL to user's avatar image
   * @param {string} [userData.bio] - User bio
   * @returns {Promise<Object>} Updated user object
   */
  async update(id, userData) {
    const { username, email, avatar_url, bio } = userData;
    
    try {
      // Create dynamic query
      let query = 'UPDATE users SET updated_at = NOW()';
      const values = [];
      let paramIndex = 1;
      
      if (username) {
        query += `, username = $${paramIndex}`;
        values.push(username);
        paramIndex++;
      }
      
      if (email) {
        query += `, email = $${paramIndex}`;
        values.push(email);
        paramIndex++;
      }
      
      if (avatar_url !== undefined) {
        query += `, avatar_url = $${paramIndex}`;
        values.push(avatar_url);
        paramIndex++;
      }
      
      if (bio !== undefined) {
        query += `, bio = $${paramIndex}`;
        values.push(bio);
        paramIndex++;
      }
      
      // Add WHERE clause and RETURNING
      query += ` WHERE id = $${paramIndex} RETURNING id, username, email, avatar_url, bio, role, reputation, created_at, updated_at`;
      values.push(id);
      
      const result = await db.query(query, values);
      
      if (result.rows.length === 0) {
        throw new Error('User not found');
      }
      
      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to update user: ${error.message}`);
    }
  }

  /**
   * Update user's password
   * @param {number} id - User ID
   * @param {string} passwordHash - New password hash
   * @returns {Promise<boolean>} True if password was updated
   */
  async updatePassword(id, passwordHash) {
    try {
      const result = await db.query(
        'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2 RETURNING id',
        [passwordHash, id]
      );
      
      if (result.rows.length === 0) {
        throw new Error('User not found');
      }
      
      return true;
    } catch (error) {
      throw new Error(`Failed to update password: ${error.message}`);
    }
  }

  /**
   * Update user's reputation
   * @param {number} id - User ID
   * @param {number} reputation - Reputation change (positive or negative)
   * @returns {Promise<number>} New reputation value
   */
  async updateReputation(id, reputation) {
    try {
      const result = await db.query(
        'UPDATE users SET reputation = reputation + $1, updated_at = NOW() WHERE id = $2 RETURNING reputation',
        [reputation, id]
      );
      
      if (result.rows.length === 0) {
        throw new Error('User not found');
      }
      
      return result.rows[0].reputation;
    } catch (error) {
      throw new Error(`Failed to update reputation: ${error.message}`);
    }
  }

  /**
   * Delete user
   * @param {number} id - User ID
   * @returns {Promise<boolean>} True if user was deleted
   */
  async delete(id) {
    try {
      const result = await db.query(
        'DELETE FROM users WHERE id = $1 RETURNING id',
        [id]
      );
      
      if (result.rows.length === 0) {
        throw new Error('User not found');
      }
      
      return true;
    } catch (error) {
      throw new Error(`Failed to delete user: ${error.message}`);
    }
  }

  /**
   * Get users with pagination
   * @param {Object} options - Pagination options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=10] - Number of users per page
   * @returns {Promise<Object>} Paginated users
   */
  async getUsers({ page = 1, limit = 10 }) {
    try {
      const offset = (page - 1) * limit;
      
      const usersQuery = await db.query(
        `SELECT id, username, email, avatar_url, bio, role, reputation, created_at, updated_at
         FROM users
         ORDER BY created_at DESC
         LIMIT $1 OFFSET $2`,
        [limit, offset]
      );
      
      const countQuery = await db.query('SELECT COUNT(*) as total FROM users');
      const total = parseInt(countQuery.rows[0].total);
      
      return {
        users: usersQuery.rows,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      throw new Error(`Failed to get users: ${error.message}`);
    }
  }
}

module.exports = new User();
