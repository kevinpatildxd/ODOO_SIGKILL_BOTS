const Vote = require('../models/Vote');
const Question = require('../models/Question');
const Answer = require('../models/Answer');
const Notification = require('../models/Notification');

class VoteService {
  /**
   * Vote on a question or answer
   * @param {Object} voteData - Vote data
   * @param {number} voteData.user_id - User ID
   * @param {string} voteData.target_type - Target type ('question' or 'answer')
   * @param {number} voteData.target_id - Target ID (question or answer ID)
   * @param {number} voteData.vote_type - Vote type (1 for upvote, -1 for downvote)
   * @returns {Promise<Object>} Vote result
   */
  async vote(voteData) {
    const { user_id, target_type, target_id, vote_type } = voteData;

    try {
      // Validate target exists
      if (target_type === 'question') {
        const question = await Question.getById(target_id);
        if (!question) {
          throw new Error('Question not found');
        }
      } else if (target_type === 'answer') {
        const answer = await Answer.getById(target_id);
        if (!answer) {
          throw new Error('Answer not found');
        }
      }

      // Process the vote
      const result = await Vote.vote({
        user_id,
        target_type,
        target_id,
        vote_type
      });

      // Create notification for upvotes
      if (vote_type === 1) {
        await Notification.notifyVote({
          target_type,
          target_id,
          voter_id: user_id,
          vote_type
        });
      }

      return result;
    } catch (error) {
      throw new Error(`Failed to process vote: ${error.message}`);
    }
  }

  /**
   * Vote on a question
   * @param {number} questionId - Question ID
   * @param {number} userId - User ID
   * @param {number} voteType - Vote type (1 for upvote, -1 for downvote)
   * @returns {Promise<Object>} Vote result
   */
  async voteQuestion(questionId, userId, voteType) {
    return this.vote({
      user_id: userId,
      target_type: 'question',
      target_id: questionId,
      vote_type: voteType
    });
  }

  /**
   * Vote on an answer
   * @param {number} answerId - Answer ID
   * @param {number} userId - User ID
   * @param {number} voteType - Vote type (1 for upvote, -1 for downvote)
   * @returns {Promise<Object>} Vote result
   */
  async voteAnswer(answerId, userId, voteType) {
    return this.vote({
      user_id: userId,
      target_type: 'answer',
      target_id: answerId,
      vote_type: voteType
    });
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
      return await Vote.getUserVote(userId, targetType, targetId);
    } catch (error) {
      throw new Error(`Failed to get user vote: ${error.message}`);
    }
  }

  /**
   * Get user's vote on a question
   * @param {number} questionId - Question ID
   * @param {number} userId - User ID
   * @returns {Promise<number>} Vote type (1, -1, or 0 if not voted)
   */
  async getUserQuestionVote(questionId, userId) {
    return this.getUserVote(userId, 'question', questionId);
  }

  /**
   * Get user's vote on an answer
   * @param {number} answerId - Answer ID
   * @param {number} userId - User ID
   * @returns {Promise<number>} Vote type (1, -1, or 0 if not voted)
   */
  async getUserAnswerVote(answerId, userId) {
    return this.getUserVote(userId, 'answer', answerId);
  }

  /**
   * Get all votes for a target
   * @param {string} targetType - Target type ('question' or 'answer')
   * @param {number} targetId - Target ID (question or answer ID)
   * @returns {Promise<Object>} Vote counts
   */
  async getVotesForTarget(targetType, targetId) {
    try {
      return await Vote.getVotesForTarget(targetType, targetId);
    } catch (error) {
      throw new Error(`Failed to get votes for target: ${error.message}`);
    }
  }

  /**
   * Get votes for a question
   * @param {number} questionId - Question ID
   * @returns {Promise<Object>} Vote counts
   */
  async getVotesForQuestion(questionId) {
    return this.getVotesForTarget('question', questionId);
  }

  /**
   * Get votes for an answer
   * @param {number} answerId - Answer ID
   * @returns {Promise<Object>} Vote counts
   */
  async getVotesForAnswer(answerId) {
    return this.getVotesForTarget('answer', answerId);
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
      return await Vote.getVotersByTarget(targetType, targetId, voteType);
    } catch (error) {
      throw new Error(`Failed to get voters for target: ${error.message}`);
    }
  }

  /**
   * Get users who upvoted a question
   * @param {number} questionId - Question ID
   * @returns {Promise<Array>} Array of user IDs
   */
  async getQuestionUpvoters(questionId) {
    return this.getVotersByTarget('question', questionId, 1);
  }

  /**
   * Get users who downvoted a question
   * @param {number} questionId - Question ID
   * @returns {Promise<Array>} Array of user IDs
   */
  async getQuestionDownvoters(questionId) {
    return this.getVotersByTarget('question', questionId, -1);
  }

  /**
   * Get users who upvoted an answer
   * @param {number} answerId - Answer ID
   * @returns {Promise<Array>} Array of user IDs
   */
  async getAnswerUpvoters(answerId) {
    return this.getVotersByTarget('answer', answerId, 1);
  }

  /**
   * Get users who downvoted an answer
   * @param {number} answerId - Answer ID
   * @returns {Promise<Array>} Array of user IDs
   */
  async getAnswerDownvoters(answerId) {
    return this.getVotersByTarget('answer', answerId, -1);
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
      return await Vote.getTargetsVotedByUser(userId, targetType, voteType);
    } catch (error) {
      throw new Error(`Failed to get targets voted by user: ${error.message}`);
    }
  }

  /**
   * Get questions upvoted by a user
   * @param {number} userId - User ID
   * @returns {Promise<Array>} Array of question IDs
   */
  async getQuestionsUpvotedByUser(userId) {
    return this.getTargetsVotedByUser(userId, 'question', 1);
  }

  /**
   * Get questions downvoted by a user
   * @param {number} userId - User ID
   * @returns {Promise<Array>} Array of question IDs
   */
  async getQuestionsDownvotedByUser(userId) {
    return this.getTargetsVotedByUser(userId, 'question', -1);
  }

  /**
   * Get answers upvoted by a user
   * @param {number} userId - User ID
   * @returns {Promise<Array>} Array of answer IDs
   */
  async getAnswersUpvotedByUser(userId) {
    return this.getTargetsVotedByUser(userId, 'answer', 1);
  }

  /**
   * Get answers downvoted by a user
   * @param {number} userId - User ID
   * @returns {Promise<Array>} Array of answer IDs
   */
  async getAnswersDownvotedByUser(userId) {
    return this.getTargetsVotedByUser(userId, 'answer', -1);
  }
}

module.exports = new VoteService();
