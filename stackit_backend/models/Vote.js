const db = require('../config/database');

class Vote {
  /**
   * Create or update a vote
   * @param {Object} voteData - Vote data
   * @param {number} voteData.user_id - User ID
   * @param {string} voteData.target_type - Target type ('question' or 'answer')
   * @param {number} voteData.target_id - Target ID
   * @param {number} voteData.vote_type - Vote type (1 for upvote, -1 for downvote)
   * @returns {Promise<Object>} Created or updated vote object
   */
  async createOrUpdate(voteData) {
    const { user_id, target_type, target_id, vote_type } = voteData;

    try {
      // Check if vote already exists
      const existingVote = await this.getByUserAndTarget(user_id, target_type, target_id);

      // Start a transaction
      const client = await db.getClient();

      try {
        await client.query('BEGIN');

        let result;
        let previousVoteType = 0;

        if (existingVote) {
          previousVoteType = existingVote.vote_type;
          
          // If the vote is the same, we're essentially removing it
          if (existingVote.vote_type === vote_type) {
            await client.query(
              'DELETE FROM votes WHERE user_id = $1 AND target_type = $2 AND target_id = $3',
              [user_id, target_type, target_id]
            );
            result = { removed: true, voteType: 0, previousVoteType };
          } else {
            // Update the existing vote
            const updateResult = await client.query(
              `UPDATE votes SET vote_type = $1, updated_at = NOW()
               WHERE user_id = $2 AND target_type = $3 AND target_id = $4
               RETURNING *`,
              [vote_type, user_id, target_type, target_id]
            );
            result = updateResult.rows[0];
            result.previousVoteType = previousVoteType;
          }
        } else {
          // Create a new vote
          const insertResult = await client.query(
            `INSERT INTO votes (user_id, target_type, target_id, vote_type)
             VALUES ($1, $2, $3, $4)
             RETURNING *`,
            [user_id, target_type, target_id, vote_type]
          );
          result = insertResult.rows[0];
          result.previousVoteType = 0;
        }

        // Calculate the vote change
        let voteChange = 0;
        if (result.removed) {
          // If vote was removed, we need to subtract the previous vote
          voteChange = -previousVoteType;
        } else {
          // If new vote or updated vote
          voteChange = vote_type - previousVoteType;
        }

        // Update the target's vote count
        if (target_type === 'question') {
          await client.query(
            'UPDATE questions SET vote_count = vote_count + $1 WHERE id = $2',
            [voteChange, target_id]
          );
        } else if (target_type === 'answer') {
          await client.query(
            'UPDATE answers SET vote_count = vote_count + $1 WHERE id = $2',
            [voteChange, target_id]
          );
        }

        await client.query('COMMIT');

        // Include the vote change in the result
        result.voteChange = voteChange;
        return result;
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    } catch (error) {
      throw new Error(`Failed to create or update vote: ${error.message}`);
    }
  }

  /**
   * Remove a vote
   * @param {number} userId - User ID
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID
   * @returns {Promise<Object>} Result with vote change
   */
  async remove(userId, targetType, targetId) {
    try {
      // Check if vote exists
      const existingVote = await this.getByUserAndTarget(userId, targetType, targetId);
      
      if (!existingVote) {
        throw new Error('Vote not found');
      }

      // Start a transaction
      const client = await db.getClient();
      
      try {
        await client.query('BEGIN');
        
        // Delete the vote
        await client.query(
          'DELETE FROM votes WHERE user_id = $1 AND target_type = $2 AND target_id = $3',
          [userId, targetType, targetId]
        );
        
        // Update the target's vote count (subtract the vote type)
        const voteChange = -existingVote.vote_type;
        
        if (targetType === 'question') {
          await client.query(
            'UPDATE questions SET vote_count = vote_count + $1 WHERE id = $2',
            [voteChange, targetId]
          );
        } else if (targetType === 'answer') {
          await client.query(
            'UPDATE answers SET vote_count = vote_count + $1 WHERE id = $2',
            [voteChange, targetId]
          );
        }
        
        await client.query('COMMIT');
        
        return { 
          removed: true, 
          previousVoteType: existingVote.vote_type,
          voteChange 
        };
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    } catch (error) {
      throw new Error(`Failed to remove vote: ${error.message}`);
    }
  }

  /**
   * Get a vote by user and target
   * @param {number} userId - User ID
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID
   * @returns {Promise<Object|null>} Vote object or null if not found
   */
  async getByUserAndTarget(userId, targetType, targetId) {
    try {
      const result = await db.query(
        'SELECT * FROM votes WHERE user_id = $1 AND target_type = $2 AND target_id = $3',
        [userId, targetType, targetId]
      );
      
      return result.rows[0] || null;
    } catch (error) {
      throw new Error(`Failed to get vote: ${error.message}`);
    }
  }

  /**
   * Get vote counts for a target
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID
   * @returns {Promise<Object>} Vote counts (upvotes, downvotes, total)
   */
  async getVoteCounts(targetType, targetId) {
    try {
      const result = await db.query(
        `SELECT
           SUM(CASE WHEN vote_type = 1 THEN 1 ELSE 0 END) as upvotes,
           SUM(CASE WHEN vote_type = -1 THEN 1 ELSE 0 END) as downvotes,
           SUM(vote_type) as total
         FROM votes
         WHERE target_type = $1 AND target_id = $2`,
        [targetType, targetId]
      );
      
      const counts = result.rows[0];
      
      return {
        upvotes: parseInt(counts.upvotes || 0),
        downvotes: parseInt(counts.downvotes || 0),
        total: parseInt(counts.total || 0)
      };
    } catch (error) {
      throw new Error(`Failed to get vote counts: ${error.message}`);
    }
  }
}

module.exports = new Vote();
