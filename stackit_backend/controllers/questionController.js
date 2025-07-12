/**
 * Question Controller
 * Handles HTTP requests related to questions
 */
const questionService = require('../services/questionService');
const { HTTP_STATUS } = require('../utils/constants');

class QuestionController {
  /**
   * Get all questions with pagination, search, and filtering
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getAllQuestions(req, res, next) {
    try {
      const { 
        page = 1, 
        limit = 10, 
        search = '', 
        tags = [], 
        sort = 'newest' 
      } = req.query;

      // Convert tags to array if it's a string
      const tagsArray = Array.isArray(tags) ? tags : tags ? [tags] : [];
      
      const result = await questionService.getQuestions({
        page: parseInt(page),
        limit: parseInt(limit),
        search,
        tags: tagsArray,
        sort
      });

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Questions retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get a question by ID
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getQuestionById(req, res, next) {
    try {
      const { id } = req.params;
      const result = await questionService.getQuestionById(parseInt(id));

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Question retrieved successfully'
      });
    } catch (error) {
      if (error.message === 'Question not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Question not found'
        });
      }
      next(error);
    }
  }

  /**
   * Get a question by slug
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getQuestionBySlug(req, res, next) {
    try {
      const { slug } = req.params;
      const result = await questionService.getQuestionBySlug(slug);

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Question retrieved successfully'
      });
    } catch (error) {
      if (error.message === 'Question not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Question not found'
        });
      }
      next(error);
    }
  }

  /**
   * Create a new question
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async createQuestion(req, res, next) {
    try {
      const { title, description, tags } = req.body;
      const userId = req.user.id;

      const result = await questionService.createQuestion({
        title,
        description,
        user_id: userId,
        tags
      });

      res.status(HTTP_STATUS.CREATED).json({
        success: true,
        data: result,
        message: 'Question created successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update a question
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async updateQuestion(req, res, next) {
    try {
      const { id } = req.params;
      const { title, description, tags } = req.body;
      const userId = req.user.id;
      const userRole = req.user.role;

      // Check if user can edit this question
      const canEdit = await questionService.canEditQuestion(
        parseInt(id),
        userId,
        userRole
      );

      if (!canEdit) {
        return res.status(HTTP_STATUS.FORBIDDEN).json({
          success: false,
          message: 'You do not have permission to update this question'
        });
      }

      const result = await questionService.updateQuestion(parseInt(id), {
        title,
        description,
        tags
      });

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Question updated successfully'
      });
    } catch (error) {
      if (error.message === 'Question not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Question not found'
        });
      }
      next(error);
    }
  }

  /**
   * Delete a question
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async deleteQuestion(req, res, next) {
    try {
      const { id } = req.params;
      const userId = req.user.id;
      const userRole = req.user.role;

      // Check if user can delete this question
      const canEdit = await questionService.canEditQuestion(
        parseInt(id),
        userId,
        userRole
      );

      if (!canEdit) {
        return res.status(HTTP_STATUS.FORBIDDEN).json({
          success: false,
          message: 'You do not have permission to delete this question'
        });
      }

      await questionService.deleteQuestion(parseInt(id));

      res.status(HTTP_STATUS.OK).json({
        success: true,
        message: 'Question deleted successfully'
      });
    } catch (error) {
      if (error.message === 'Question not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Question not found'
        });
      }
      next(error);
    }
  }

  /**
   * Get questions by a specific tag
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getQuestionsByTag(req, res, next) {
    try {
      const { tag } = req.params;
      const { page = 1, limit = 10 } = req.query;

      const result = await questionService.getQuestionsByTag(tag, {
        page: parseInt(page),
        limit: parseInt(limit)
      });

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Questions retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get questions by user
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getQuestionsByUser(req, res, next) {
    try {
      const { userId } = req.params;
      const { page = 1, limit = 10 } = req.query;

      const result = await questionService.getQuestionsByUser(parseInt(userId), {
        page: parseInt(page),
        limit: parseInt(limit)
      });

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Questions retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Accept an answer for a question
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async acceptAnswer(req, res, next) {
    try {
      const { questionId, answerId } = req.params;
      const userId = req.user.id;

      const result = await questionService.acceptAnswer(
        parseInt(questionId),
        parseInt(answerId),
        userId
      );

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Answer accepted successfully'
      });
    } catch (error) {
      if (error.message === 'Question not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Question not found'
        });
      }
      if (error.message === 'Only the question author can accept an answer') {
        return res.status(HTTP_STATUS.FORBIDDEN).json({
          success: false,
          message: 'Only the question author can accept an answer'
        });
      }
      next(error);
    }
  }

  /**
   * Unaccept a previously accepted answer
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async unacceptAnswer(req, res, next) {
    try {
      const { questionId } = req.params;
      const userId = req.user.id;

      const result = await questionService.unacceptAnswer(
        parseInt(questionId),
        userId
      );

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Answer acceptance removed successfully'
      });
    } catch (error) {
      if (error.message === 'Question not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Question not found'
        });
      }
      if (error.message === 'Only the question author can unaccept an answer') {
        return res.status(HTTP_STATUS.FORBIDDEN).json({
          success: false,
          message: 'Only the question author can unaccept an answer'
        });
      }
      next(error);
    }
  }
}

module.exports = new QuestionController();
