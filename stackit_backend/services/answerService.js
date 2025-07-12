const Answer = require('../models/Answer');
const Question = require('../models/Question');
const User = require('../models/User');
const Notification = require('../models/Notification');

class AnswerService {
  /**
   * Create a new answer
   * @param {Object} answerData - Answer data
   * @param {string} answerData.content - Answer content
   * @param {number} answerData.question_id - Question ID
   * @param {number} answerData.user_id - User ID
   * @returns {Promise<Object>} Created answer object
   */
  async createAnswer(answerData) {
    const { content, question_id, user_id } = answerData;

    try {
      // Check if question exists
      const question = await Question.getById(question_id);
      if (!question) {
        throw new Error('Question not found');
      }

      // Create the answer
      const answer = await Answer.create({
        content,
        question_id,
        user_id
      });

      // Get user data for the response
      const user = await User.getById(user_id);
      if (user) {
        answer.username = user.username;
        answer.avatar_url = user.avatar_url;
      }

      // Create notification for the question author
      if (question.user_id !== user_id) {
        await Notification.notifyNewAnswer({
          answer_id: answer.id,
          question_id: question_id,
          answer_user_id: user_id,
          question_title: question.title
        });
      }

      return answer;
    } catch (error) {
      throw new Error(`Failed to create answer: ${error.message}`);
    }
  }

  /**
   * Get answer by ID
   * @param {number} id - Answer ID
   * @returns {Promise<Object>} Answer object with user details
   */
  async getAnswerById(id) {
    try {
      const answer = await Answer.getById(id);
      if (!answer) {
        throw new Error('Answer not found');
      }
      return answer;
    } catch (error) {
      throw new Error(`Failed to get answer: ${error.message}`);
    }
  }

  /**
   * Update answer
   * @param {number} id - Answer ID
   * @param {number} userId - User ID (for ownership check)
   * @param {Object} answerData - Answer data to update
   * @param {string} [answerData.content] - Answer content
   * @returns {Promise<Object>} Updated answer object
   */
  async updateAnswer(id, userId, answerData) {
    try {
      // Check if answer exists and belongs to the user
      const existingAnswer = await Answer.getById(id);
      if (!existingAnswer) {
        throw new Error('Answer not found');
      }

      if (existingAnswer.user_id !== userId) {
        throw new Error('You do not have permission to update this answer');
      }

      // Update the answer
      const answer = await Answer.update(id, answerData);

      // Get user data for the response
      const user = await User.getById(userId);
      if (user) {
        answer.username = user.username;
        answer.avatar_url = user.avatar_url;
      }

      return answer;
    } catch (error) {
      throw new Error(`Failed to update answer: ${error.message}`);
    }
  }

  /**
   * Delete answer
   * @param {number} id - Answer ID
   * @param {number} userId - User ID (for ownership check)
   * @param {string} userRole - User role ('admin', 'moderator', 'user')
   * @returns {Promise<boolean>} True if answer was deleted
   */
  async deleteAnswer(id, userId, userRole) {
    try {
      // Check if answer exists
      const answer = await Answer.getById(id);
      if (!answer) {
        throw new Error('Answer not found');
      }

      // Check if user has permission to delete
      if (answer.user_id !== userId && !['admin', 'moderator'].includes(userRole)) {
        throw new Error('You do not have permission to delete this answer');
      }

      // Delete the answer
      const deleted = await Answer.delete(id);
      return deleted;
    } catch (error) {
      throw new Error(`Failed to delete answer: ${error.message}`);
    }
  }

  /**
   * Mark answer as accepted
   * @param {number} id - Answer ID
   * @param {number} userId - User ID (for question ownership check)
   * @returns {Promise<Object>} Updated answer object
   */
  async markAsAccepted(id, userId) {
    try {
      // Check if answer exists
      const answer = await Answer.getById(id);
      if (!answer) {
        throw new Error('Answer not found');
      }

      // Check if user is the question author
      const question = await Question.getById(answer.question_id);
      if (!question) {
        throw new Error('Associated question not found');
      }

      if (question.user_id !== userId) {
        throw new Error('Only the question author can accept an answer');
      }

      // Mark the answer as accepted
      const updatedAnswer = await Answer.markAsAccepted(id);

      // Create notification for answer author
      if (answer.user_id !== userId) {
        await Notification.notifyAnswerAccepted({
          answer_id: id,
          question_id: question.id,
          question_title: question.title
        });
      }

      return updatedAnswer;
    } catch (error) {
      throw new Error(`Failed to mark answer as accepted: ${error.message}`);
    }
  }

  /**
   * Remove accepted status from an answer
   * @param {number} id - Answer ID
   * @param {number} userId - User ID (for question ownership check)
   * @returns {Promise<Object>} Updated answer object
   */
  async unmarkAsAccepted(id, userId) {
    try {
      // Check if answer exists
      const answer = await Answer.getById(id);
      if (!answer) {
        throw new Error('Answer not found');
      }

      // Check if user is the question author
      const question = await Question.getById(answer.question_id);
      if (!question) {
        throw new Error('Associated question not found');
      }

      if (question.user_id !== userId) {
        throw new Error('Only the question author can unaccept an answer');
      }

      // Remove accepted status from the answer
      const updatedAnswer = await Answer.unmarkAsAccepted(id);
      return updatedAnswer;
    } catch (error) {
      throw new Error(`Failed to unmark answer as accepted: ${error.message}`);
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
  async getAnswersByQuestion(questionId, options) {
    try {
      // Check if question exists
      const question = await Question.getById(questionId);
      if (!question) {
        throw new Error('Question not found');
      }

      return await Answer.getAnswersByQuestion(questionId, options);
    } catch (error) {
      throw new Error(`Failed to get answers: ${error.message}`);
    }
  }

  /**
   * Get answers by user
   * @param {number} userId - User ID
   * @param {Object} options - Pagination options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=10] - Number of answers per page
   * @returns {Promise<Object>} Paginated answers
   */
  async getAnswersByUser(userId, options) {
    try {
      // Check if user exists
      const user = await User.getById(userId);
      if (!user) {
        throw new Error('User not found');
      }

      return await Answer.getAnswersByUser(userId, options);
    } catch (error) {
      throw new Error(`Failed to get user answers: ${error.message}`);
    }
  }

  /**
   * Check if a user can edit an answer
   * @param {number} answerId - Answer ID
   * @param {number} userId - User ID
   * @param {string} userRole - User role ('admin', 'moderator', 'user')
   * @returns {Promise<boolean>} True if user can edit the answer
   */
  async canEditAnswer(answerId, userId, userRole) {
    try {
      // Admin and moderator can edit any answer
      if (['admin', 'moderator'].includes(userRole)) {
        return true;
      }

      // Get the answer to check ownership
      const answer = await Answer.getById(answerId);
      if (!answer) {
        return false;
      }

      // Regular users can only edit their own answers
      return answer.user_id === userId;
    } catch (error) {
      throw new Error(`Failed to check edit permissions: ${error.message}`);
    }
  }
}

module.exports = new AnswerService();
