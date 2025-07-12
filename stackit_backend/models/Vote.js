const db = require('../config/database');

class Vote {
  /**
   * Create or update a vote
   * @param {Object} voteData - Vote data
   * @param {number} voteData.user_id - User ID
   * @param {string} voteData.target_type - Target type ('question' or 'answer')
   * @param {number} voteData.target_id - Target ID (question or answer ID)
   * @param {number} voteData.vote_type - Vote type (1 for upvote, -1 for downvote)
   * @returns {Promise<Object>} Vote result with counts and user's vote
   */
  async vote(voteData) {
    const { user_id, target_type, target_id, vote_type } = voteData;
    
    if (!['question', 'answer'].includes(target_type)) {
      throw new Error('Invalid target type. Must be "question" or "answer"');
    }
    
    if (![1, -1].includes(vote_type)) {
      throw new Error('Invalid vote type. Must be 1 (upvote) or -1 (downvote)');
    }
    
    try {
      const client = await db.getClient();
      
      try {
        await client.query('BEGIN');
        
        // Check if user already voted on this target
        const existingVote = await client.query(
          'SELECT id, vote_type FROM votes WHERE user_id = $1 AND target_type = $2 AND target_id = $3',
          [user_id, target_type, target_id]
        );
        
        let voteChange = vote_type;
        let voted = false;
        
        if (existingVote.rows.length > 0) {
          // User already voted
          const oldVoteType = existingVote.rows[0].vote_type;
          
          if (oldVoteType === vote_type) {
            // User is canceling their vote
            await client.query(
              'DELETE FROM votes WHERE id = $1',
              [existingVote.rows[0].id]
            );
            voteChange = -oldVoteType; // Reverse the previous vote
            voted = false;
          } else {
            // User is changing their vote direction
            await client.query(
              'UPDATE votes SET vote_type = $1, updated_at = NOW() WHERE id = $2',
              [vote_type, existingVote.rows[0].id]
            );
            voteChange = vote_type - oldVoteType; // Calculate the net change
            voted = true;
          }
        } else {
          // New vote
          await client.query(
            'INSERT INTO votes (user_id, target_type, target_id, vote_type) VALUES ($1, $2, $3, $4)',
            [user_id, target_type, target_id, vote_type]
          );
          voted = true;
        }
        
        // Update the vote count on the target
        let newVoteCount;
        if (target_type === 'question') {
          const result = await client.query(
            'UPDATE questions SET vote_count = vote_count + $1 WHERE id = $2 RETURNING vote_count',
            [voteChange, target_id]
          );
          
          if (result.rows.length === 0) {
            throw new Error('Question not found');
          }
          
          newVoteCount = result.rows[0].vote_count;
        } else {
          // target_type is 'answer'
          const result = await client.query(
            'UPDATE answers SET vote_count = vote_count + $1 WHERE id = $2 RETURNING vote_count',
            [voteChange, target_id]
          );
          
          if (result.rows.length === 0) {
            throw new Error('Answer not found');
          }
          
          newVoteCount = result.rows[0].vote_count;
        }
        
        // Update user reputation if applicable (simplified version)
        if (target_type === 'answer') {
          // Get the author of the answer
          const authorResult = await client.query(
            'SELECT user_id FROM answers WHERE id = $1',
            [target_id]
          );
          
          if (authorResult.rows.length > 0) {
            const authorId = authorResult.rows[0].user_id;
            
            // Don't update reputation for self-votes
            if (authorId !== user_id) {
              // Upvote: +10, Downvote: -2, Cancel: reverse
              let repChange = 0;
              
              if (voted) {
                repChange = vote_type === 1 ? 10 : -2;
              } else {
                // Canceled vote: reverse the reputation
                repChange = voteChange === 1 ? 2 : -10;
              }
              
              await client.query(
                'UPDATE users SET reputation = reputation + $1 WHERE id = $2',
                [repChange, authorId]
              );
            }
          }
        } else if (target_type === 'question') {
          // Get the author of the question
          const authorResult = await client.query(
            'SELECT user_id FROM questions WHERE id = $1',
            [target_id]
          );
          
          if (authorResult.rows.length > 0) {
            const authorId = authorResult.rows[0].user_id;
            
            // Don't update reputation for self-votes
            if (authorId !== user_id) {
              // Upvote: +5, Downvote: -1, Cancel: reverse
              let repChange = 0;
              
              if (voted) {
                repChange = vote_type === 1 ? 5 : -1;
              } else {
                // Canceled vote: reverse the reputation
                repChange = voteChange === 1 ? 1 : -5;
              }
              
              await client.query(
                'UPDATE users SET reputation = reputation + $1 WHERE id = $2',
                [repChange, authorId]
              );
            }
          }
        }
        
        await client.query('COMMIT');
        
        // Return current state
        return {
          vote_count: newVoteCount,
          user_vote: voted ? vote_type : 0,
          target_type,
          target_id
        };
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    } catch (error) {
      throw new Error(`Failed to process vote: ${error.message}`);
    }
  }

  /**
   * Get a user's vote on a target
   * @param {number} userId - User ID
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID (question or answer ID)
   * @returns {Promise<number>} Vote type (1, -1, or 0 if not voted)
   */
  async getUserVote(userId, targetType, targetId) {
    try {
      if (!['question', 'answer'].includes(targetType)) {
        throw new Error('Invalid target type. Must be "question" or "answer"');
      }
      
      const result = await db.query(
        'SELECT vote_type FROM votes WHERE user_id = $1 AND target_type = $2 AND target_id = $3',
        [userId, targetType, targetId]
      );
      
      if (result.rows.length === 0) {
        return 0; // User hasn't voted
      }
      
      return result.rows[0].vote_type;
    } catch (error) {
      throw new Error(`Failed to get user vote: ${error.message}`);
    }
  }

  /**
   * Get all votes for a target
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID (question or answer ID)
   * @returns {Promise<Object>} Vote counts
   */
  async getVotesForTarget(targetType, targetId) {
    try {
      if (!['question', 'answer'].includes(targetType)) {
        throw new Error('Invalid target type. Must be "question" or "answer"');
      }
      
      const result = await db.query(
        `SELECT 
          COUNT(*) FILTER (WHERE vote_type = 1) as upvotes,
          COUNT(*) FILTER (WHERE vote_type = -1) as downvotes
         FROM votes 
         WHERE target_type = $1 AND target_id = $2`,
        [targetType, targetId]
      );
      
      const { upvotes, downvotes } = result.rows[0];
      
      return {
        upvotes: parseInt(upvotes),
        downvotes: parseInt(downvotes),
        total: parseInt(upvotes) - parseInt(downvotes)
      };
    } catch (error) {
      throw new Error(`Failed to get votes for target: ${error.message}`);
    }
  }

  /**
   * Get users who voted on a target
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID (question or answer ID)
   * @param {number} voteType - Vote type (1 for upvotes, -1 for downvotes)
   * @returns {Promise<Array>} Array of user IDs
   */
  async getVotersByTarget(targetType, targetId, voteType) {
    try {
      if (!['question', 'answer'].includes(targetType)) {
        throw new Error('Invalid target type. Must be "question" or "answer"');
      }
      
      if (![1, -1].includes(voteType)) {
        throw new Error('Invalid vote type. Must be 1 (upvote) or -1 (downvote)');
      }
      
      const result = await db.query(
        `SELECT v.user_id, u.username, u.avatar_url
         FROM votes v
         JOIN users u ON v.user_id = u.id
         WHERE v.target_type = $1 AND v.target_id = $2 AND v.vote_type = $3`,
        [targetType, targetId, voteType]
      );
      
      return result.rows;
    } catch (error) {
      throw new Error(`Failed to get voters for target: ${error.message}`);
    }
  }

  /**
   * Get targets voted by a user
   * @param {number} userId - User ID
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} voteType - Vote type (1 for upvotes, -1 for downvotes)
   * @returns {Promise<Array>} Array of target IDs
   */
  async getTargetsVotedByUser(userId, targetType, voteType) {
    try {
      if (!['question', 'answer'].includes(targetType)) {
        throw new Error('Invalid target type. Must be "question" or "answer"');
      }
      
      if (![1, -1].includes(voteType)) {
        throw new Error('Invalid vote type. Must be 1 (upvote) or -1 (downvote)');
      }
      
      const result = await db.query(
        'SELECT target_id FROM votes WHERE user_id = $1 AND target_type = $2 AND vote_type = $3',
        [userId, targetType, voteType]
      );
      
      return result.rows.map(row => row.target_id);
    } catch (error) {
      throw new Error(`Failed to get targets voted by user: ${error.message}`);
    }
  }
}

module.exports = new Vote();
