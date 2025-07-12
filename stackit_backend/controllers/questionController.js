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
   * Get popular questions sorted by votes and view count
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getPopularQuestions(req, res, next) {
    try {
      const { 
        page = 1, 
        limit = 10,
        timeframe = 'week' // day, week, month, year, all
      } = req.query;
      
      const result = await questionService.getPopularQuestions({
        page: parseInt(page),
        limit: parseInt(limit),
        timeframe
      });

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Popular questions retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Get recent questions sorted by creation date
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getRecentQuestions(req, res, next) {
    try {
      const { 
        page = 1, 
        limit = 10
      } = req.query;
      
      const result = await questionService.getRecentQuestions({
        page: parseInt(page),
        limit: parseInt(limit)
      });

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Recent questions retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Search questions by query string
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async searchQuestions(req, res, next) {
    try {
      const { 
        q = '', 
        page = 1, 
        limit = 10,
        tags = []
      } = req.query;
      
      // Convert tags to array if it's a string
      const tagsArray = Array.isArray(tags) ? tags : tags ? [tags] : [];
      
      const result = await questionService.searchQuestions({
        query: q,
        page: parseInt(page),
        limit: parseInt(limit),
        tags: tagsArray
      });

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Search results retrieved successfully'
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
   * Get answers for a specific question
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getQuestionAnswers(req, res, next) {
    try {
      const { id } = req.params;
      const { 
        page = 1, 
        limit = 10,
        sort = 'votes' // votes, date
      } = req.query;
      
      const result = await questionService.getQuestionAnswers(
        parseInt(id),
        {
          page: parseInt(page),
          limit: parseInt(limit),
          sort
        }
      );

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Question answers retrieved successfully'
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
   * Create an answer for a specific question
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async createAnswer(req, res, next) {
    try {
      const { id } = req.params;
      const { content } = req.body;
      const userId = req.user.userId;

      const result = await questionService.createAnswer({
        question_id: parseInt(id),
        user_id: userId,
        content
      });

      res.status(HTTP_STATUS.CREATED).json({
        success: true,
        data: result,
        message: 'Answer created successfully'
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
   * Get questions by tag
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getQuestionsByTag(req, res, next) {
    try {
      const { tagName } = req.params;
      const { page = 1, limit = 10 } = req.query;

      const result = await questionService.getQuestionsByTag(
        tagName,
        parseInt(page),
        parseInt(limit)
      );

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: `Questions with tag '${tagName}' retrieved successfully`
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

      const result = await questionService.getQuestionsByUser(
        parseInt(userId),
        parseInt(page),
        parseInt(limit)
      );

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Questions by user retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Vote on a question
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async voteQuestion(req, res, next) {
    try {
      const { id } = req.params;
      const { vote_type } = req.body;
      const userId = req.user.userId;

      const result = await questionService.voteQuestion(
        parseInt(id),
        userId,
        vote_type
      );

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Vote recorded successfully'
      });
    } catch (error) {
      if (error.message === 'Question not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Question not found'
        });
      }
      if (error.message === 'Cannot vote on your own question') {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          success: false,
          message: 'Cannot vote on your own question'
        });
      }
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
      const userId = req.user.userId;
      const userRole = req.user.role;

      // Check if user can accept answers for this question
      const canAccept = await questionService.canAcceptAnswer(
        parseInt(questionId),
        userId,
        userRole
      );

      if (!canAccept) {
        return res.status(HTTP_STATUS.FORBIDDEN).json({
          success: false,
          message: 'You do not have permission to accept answers for this question'
        });
      }

      const result = await questionService.acceptAnswer(
        parseInt(questionId),
        parseInt(answerId)
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
      if (error.message === 'Answer not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Answer not found'
        });
      }
      next(error);
    }
  }
  
  /**
   * Get question view count
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getQuestionViewCount(req, res, next) {
    try {
      const { id } = req.params;
      const count = await questionService.getQuestionViewCount(parseInt(id));

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: { count },
        message: 'View count retrieved successfully'
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
   * Increment question view count
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async incrementViewCount(req, res, next) {
    try {
      const { id } = req.params;
      const newCount = await questionService.incrementViewCount(parseInt(id));

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: { count: newCount },
        message: 'View count incremented successfully'
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
   * Unaccept a previously accepted answer
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async unacceptAnswer(req, res, next) {
    try {
      const { questionId } = req.params;
      const userId = req.user.userId;
      const userRole = req.user.role;

      // Check if user can accept answers for this question
      const canAccept = await questionService.canAcceptAnswer(
        parseInt(questionId),
        userId,
        userRole
      );

      if (!canAccept) {
        return res.status(HTTP_STATUS.FORBIDDEN).json({
          success: false,
          message: 'You do not have permission to unaccept answers for this question'
        });
      }

      const result = await questionService.unacceptAnswer(parseInt(questionId));

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Answer unaccepted successfully'
      });
    } catch (error) {
      if (error.message === 'Question not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Question not found'
        });
      }
      if (error.message === 'No accepted answer to unaccept') {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          success: false,
          message: 'No accepted answer to unaccept'
        });
      }
      next(error);
    }
  }
}

module.exports = new QuestionController();
