/**
 * Vote Service
 * Business logic for vote operations
 */
const Vote = require('../models/Vote');
const Question = require('../models/Question');
const Answer = require('../models/Answer');
const Notification = require('../models/Notification');
const User = require('../models/User');

class VoteService {
  /**
   * Cast a vote on a question or answer
   * @param {number} userId - User ID
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID
   * @param {number} voteType - Vote type (1 for upvote, -1 for downvote)
   * @returns {Promise<Object>} Vote result with updated vote count
   */
  async vote(userId, targetType, targetId, voteType) {
    try {
      // Validate input
      if (!['question', 'answer'].includes(targetType)) {
        throw new Error('Invalid target type. Must be "question" or "answer"');
      }

      if (![1, -1].includes(voteType)) {
        throw new Error('Invalid vote type. Must be 1 (upvote) or -1 (downvote)');
      }

      // Check if target exists
      let targetAuthorId;
      if (targetType === 'question') {
        const question = await Question.getById(targetId);
        if (!question) {
          throw new Error('Question not found');
        }
        targetAuthorId = question.user_id;
      } else {
        const answer = await Answer.getById(targetId);
        if (!answer) {
          throw new Error('Answer not found');
        }
        targetAuthorId = answer.user_id;
      }

      // Prevent voting on your own content
      if (targetAuthorId === userId) {
        throw new Error('You cannot vote on your own content');
      }

      // Process the vote
      const result = await Vote.createOrUpdate({
        user_id: userId,
        target_type: targetType,
        target_id: targetId,
        vote_type: voteType
      });

      // Get updated vote count
      const voteCount = await Vote.getVoteCounts(targetType, targetId);

      // Update user reputation if needed
      if (!result.removed) {
        await this._updateUserReputation(targetAuthorId, targetType, voteType, result.previousVoteType);
      }

      // Create notification for the target author
      await this._createVoteNotification(userId, targetAuthorId, targetType, targetId, voteType, result.removed);

      return {
        targetType,
        targetId,
        voteType: result.removed ? 0 : voteType,
        previousVoteType: result.previousVoteType,
        voteCount
      };
    } catch (error) {
      throw new Error(`Failed to process vote: ${error.message}`);
    }
  }

  /**
   * Get user's vote on a target
   * @param {number} userId - User ID
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID
   * @returns {Promise<Object>} User vote information
   */
  async getUserVote(userId, targetType, targetId) {
    try {
      // Validate input
      if (!['question', 'answer'].includes(targetType)) {
        throw new Error('Invalid target type. Must be "question" or "answer"');
      }

      const vote = await Vote.getByUserAndTarget(userId, targetType, targetId);
      const voteCount = await Vote.getVoteCounts(targetType, targetId);

      return {
        targetType,
        targetId,
        voteType: vote ? vote.vote_type : 0,
        voteCount
      };
    } catch (error) {
      throw new Error(`Failed to get user vote: ${error.message}`);
    }
  }

  /**
   * Remove a vote
   * @param {number} userId - User ID
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID
   * @returns {Promise<Object>} Result with updated vote count
   */
  async removeVote(userId, targetType, targetId) {
    try {
      // Validate input
      if (!['question', 'answer'].includes(targetType)) {
        throw new Error('Invalid target type. Must be "question" or "answer"');
      }

      // Check if vote exists
      const existingVote = await Vote.getByUserAndTarget(userId, targetType, targetId);
      if (!existingVote) {
        throw new Error('Vote not found');
      }

      // Get target author before removing vote
      let targetAuthorId;
      if (targetType === 'question') {
        const question = await Question.getById(targetId);
        if (question) {
          targetAuthorId = question.user_id;
        }
      } else {
        const answer = await Answer.getById(targetId);
        if (answer) {
          targetAuthorId = answer.user_id;
        }
      }

      // Remove the vote
      const result = await Vote.remove(userId, targetType, targetId);

      // Update user reputation if needed
      if (targetAuthorId) {
        await this._updateUserReputation(targetAuthorId, targetType, 0, existingVote.vote_type);
      }

      // Get updated vote count
      const voteCount = await Vote.getVoteCounts(targetType, targetId);

      return {
        targetType,
        targetId,
        voteType: 0,
        previousVoteType: existingVote.vote_type,
        voteCount
      };
    } catch (error) {
      throw new Error(`Failed to remove vote: ${error.message}`);
    }
  }

  /**
   * Get vote counts for a target
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID
   * @returns {Promise<Object>} Vote counts
   */
  async getVoteCounts(targetType, targetId) {
    try {
      // Validate input
      if (!['question', 'answer'].includes(targetType)) {
        throw new Error('Invalid target type. Must be "question" or "answer"');
      }

      return await Vote.getVoteCounts(targetType, targetId);
    } catch (error) {
      throw new Error(`Failed to get vote counts: ${error.message}`);
    }
  }

  /**
   * Update user reputation based on votes
   * @private
   * @param {number} userId - User ID
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} newVoteType - New vote type (1, -1, or 0 for removed)
   * @param {number} previousVoteType - Previous vote type (1, -1, or 0)
   * @returns {Promise<void>}
   */
  async _updateUserReputation(userId, targetType, newVoteType, previousVoteType) {
    try {
      // Calculate reputation change
      let repChange = 0;
      
      // Reverse previous vote impact if any
      if (previousVoteType !== 0) {
        if (targetType === 'question') {
          repChange -= previousVoteType === 1 ? 5 : -2;
        } else { // answer
          repChange -= previousVoteType === 1 ? 10 : -2;
        }
      }
      
      // Add new vote impact if any
      if (newVoteType !== 0) {
        if (targetType === 'question') {
          repChange += newVoteType === 1 ? 5 : -2;
        } else { // answer
          repChange += newVoteType === 1 ? 10 : -2;
        }
      }
      
      // Update user reputation if there's a change
      if (repChange !== 0) {
        await User.updateReputation(userId, repChange);
      }
    } catch (error) {
      console.error(`Failed to update reputation: ${error.message}`);
      // Don't throw error to prevent vote operation from failing
    }
  }

  /**
   * Create notification for vote
   * @private
   * @param {number} voterId - User ID who voted
   * @param {number} recipientId - User ID who receives the notification
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID
   * @param {number} voteType - Vote type (1, -1)
   * @param {boolean} removed - Whether vote was removed
   * @returns {Promise<void>}
   */
  async _createVoteNotification(voterId, recipientId, targetType, targetId, voteType, removed) {
    try {
      // Don't notify for downvotes to avoid negative notifications
      // Don't notify if vote was removed
      if (voteType === -1 || removed) {
        return;
      }
      
      // Get voter info
      const voter = await User.getById(voterId);
      if (!voter) return;
      
      let title;
      let content;
      
      // Get content info
      if (targetType === 'question') {
        const question = await Question.getById(targetId);
        if (!question) return;
        
        title = 'Someone upvoted your question';
        content = `${voter.username} upvoted your question: "${question.title.substring(0, 50)}${question.title.length > 50 ? '...' : ''}"`;
      } else {
        const answer = await Answer.getById(targetId);
        if (!answer) return;
        
        const question = await Question.getById(answer.question_id);
        if (!question) return;
        
        title = 'Someone upvoted your answer';
        content = `${voter.username} upvoted your answer on: "${question.title.substring(0, 50)}${question.title.length > 50 ? '...' : ''}"`;
      }
      
      // Create notification
      await Notification.create({
        user_id: recipientId,
        type: 'vote',
        title,
        message: content,
        reference_type: targetType,
        reference_id: targetId
      });
    } catch (error) {
      console.error(`Failed to create vote notification: ${error.message}`);
      // Don't throw error to prevent vote operation from failing
    }
  }
}

module.exports = new VoteService();
