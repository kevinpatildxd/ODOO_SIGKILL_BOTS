const Question = require('../models/Question');
const Tag = require('../models/Tag');
const User = require('../models/User');

class QuestionService {
  /**
   * Create a new question
   * @param {Object} questionData - Question data
   * @param {string} questionData.title - Question title
   * @param {string} questionData.description - Question description
   * @param {number} questionData.user_id - User ID
   * @param {Array<string>} [questionData.tags] - Array of tag names
   * @returns {Promise<Object>} Created question with tags
   */
  async createQuestion(questionData) {
    const { title, description, user_id, tags = [] } = questionData;

    try {
      // Create the question
      const question = await Question.create({
        title,
        description,
        user_id
      });

      // Add tags if provided
      if (tags && tags.length > 0) {
        const processedTags = await Tag.addTagsToQuestion(question.id, tags);
        question.tags = processedTags.map(tag => tag.name);
      } else {
        question.tags = [];
      }

      // Get the user's username for the response
      const user = await User.getById(user_id);
      if (user) {
        question.username = user.username;
        question.avatar_url = user.avatar_url;
      }

      return question;
    } catch (error) {
      throw new Error(`Failed to create question: ${error.message}`);
    }
  }

  /**
   * Get a question by ID
   * @param {number} id - Question ID
   * @param {boolean} [incrementView=true] - Whether to increment the view count
   * @returns {Promise<Object>} Question object with tags and user details
   */
  async getQuestionById(id, incrementView = true) {
    try {
      const question = await Question.getById(id);
      if (!question) {
        throw new Error('Question not found');
      }

      // Increment view count if requested
      if (incrementView) {
        await Question.incrementViewCount(id);
        question.view_count += 1;
      }

      return question;
    } catch (error) {
      throw new Error(`Failed to get question: ${error.message}`);
    }
  }

  /**
   * Get a question by slug
   * @param {string} slug - Question slug
   * @param {boolean} [incrementView=true] - Whether to increment the view count
   * @returns {Promise<Object>} Question object with tags and user details
   */
  async getQuestionBySlug(slug, incrementView = true) {
    try {
      const question = await Question.getBySlug(slug);
      if (!question) {
        throw new Error('Question not found');
      }

      // Increment view count if requested
      if (incrementView) {
        await Question.incrementViewCount(question.id);
        question.view_count += 1;
      }

      return question;
    } catch (error) {
      throw new Error(`Failed to get question: ${error.message}`);
    }
  }

  /**
   * Update a question
   * @param {number} id - Question ID
   * @param {Object} questionData - Question data to update
   * @param {string} [questionData.title] - Question title
   * @param {string} [questionData.description] - Question description
   * @param {string} [questionData.status] - Question status
   * @param {Array<string>} [questionData.tags] - Array of tag names
   * @returns {Promise<Object>} Updated question with tags
   */
  async updateQuestion(id, questionData) {
    const { title, description, status, tags } = questionData;

    try {
      // First, get the question to check ownership
      const existingQuestion = await Question.getById(id);
      if (!existingQuestion) {
        throw new Error('Question not found');
      }

      // Update the question
      const updateData = {};
      if (title !== undefined) updateData.title = title;
      if (description !== undefined) updateData.description = description;
      if (status !== undefined) updateData.status = status;

      const question = await Question.update(id, updateData);

      // Update tags if provided
      if (tags !== undefined) {
        // Get current tags
        const currentTags = await Tag.getTagsForQuestion(id);
        
        // Process tags: First add all new ones
        const processedTags = await Tag.addTagsToQuestion(id, tags);
        question.tags = processedTags.map(tag => tag.name);
        
        // Then remove any that are not in the new list
        const newTagNames = tags.map(t => t.toLowerCase());
        for (const currentTag of currentTags) {
          if (!newTagNames.includes(currentTag.name.toLowerCase())) {
            await Tag.removeTagFromQuestion(id, currentTag.id);
          }
        }
      }

      // Get the user's username for the response
      const user = await User.getById(question.user_id);
      if (user) {
        question.username = user.username;
        question.avatar_url = user.avatar_url;
      }

      return question;
    } catch (error) {
      throw new Error(`Failed to update question: ${error.message}`);
    }
  }

  /**
   * Delete a question
   * @param {number} id - Question ID
   * @returns {Promise<boolean>} True if question was deleted
   */
  async deleteQuestion(id) {
    try {
      const deleted = await Question.delete(id);
      return deleted;
    } catch (error) {
      throw new Error(`Failed to delete question: ${error.message}`);
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
   * @param {number} [options.user_id] - Filter by user ID
   * @returns {Promise<Object>} Paginated questions
   */
  async getQuestions(options) {
    try {
      return await Question.getQuestions(options);
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
  async getQuestionsByTag(tag, options) {
    try {
      return await Question.getQuestionsByTag(tag, options);
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
  async getQuestionsByUser(userId, options) {
    try {
      return await Question.getQuestionsByUser(userId, options);
    } catch (error) {
      throw new Error(`Failed to get questions by user: ${error.message}`);
    }
  }

  /**
   * Accept an answer for a question
   * @param {number} questionId - Question ID
   * @param {number} answerId - Answer ID to accept
   * @param {number} userId - User ID making the request (for ownership check)
   * @returns {Promise<Object>} Updated question
   */
  async acceptAnswer(questionId, answerId, userId) {
    try {
      // Check if the question exists and belongs to the user
      const question = await Question.getById(questionId);
      if (!question) {
        throw new Error('Question not found');
      }

      if (question.user_id !== userId) {
        throw new Error('Only the question author can accept an answer');
      }

      // Update the question with the accepted answer ID
      const updatedQuestion = await Question.update(questionId, {
        accepted_answer_id: answerId
      });

      return updatedQuestion;
    } catch (error) {
      throw new Error(`Failed to accept answer: ${error.message}`);
    }
  }

  /**
   * Remove an accepted answer from a question
   * @param {number} questionId - Question ID
   * @param {number} userId - User ID making the request (for ownership check)
   * @returns {Promise<Object>} Updated question
   */
  async unacceptAnswer(questionId, userId) {
    try {
      // Check if the question exists and belongs to the user
      const question = await Question.getById(questionId);
      if (!question) {
        throw new Error('Question not found');
      }

      if (question.user_id !== userId) {
        throw new Error('Only the question author can unaccept an answer');
      }

      // Update the question to remove the accepted answer ID
      const updatedQuestion = await Question.update(questionId, {
        accepted_answer_id: null
      });

      return updatedQuestion;
    } catch (error) {
      throw new Error(`Failed to unaccept answer: ${error.message}`);
    }
  }

  /**
   * Check if a user can edit a question
   * @param {number} questionId - Question ID
   * @param {number} userId - User ID
   * @param {string} userRole - User role ('admin', 'moderator', 'user')
   * @returns {Promise<boolean>} True if user can edit the question
   */
  async canEditQuestion(questionId, userId, userRole) {
    try {
      // Admin and moderator can edit any question
      if (['admin', 'moderator'].includes(userRole)) {
        return true;
      }

      // Get the question to check ownership
      const question = await Question.getById(questionId);
      if (!question) {
        return false;
      }

      // Regular users can only edit their own questions
      return question.user_id === userId;
    } catch (error) {
      throw new Error(`Failed to check edit permissions: ${error.message}`);
    }
  }
}

module.exports = new QuestionService();
