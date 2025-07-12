/**
 * Answer Controller
 * Handles all answer-related HTTP requests
 */
const answerService = require('../services/answerService');

class AnswerController {
  /**
   * Create a new answer
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async createAnswer(req, res, next) {
    try {
      const { content, question_id } = req.body;
      const user_id = req.user.id;

      const answer = await answerService.createAnswer({
        content,
        question_id,
        user_id
      });

      res.status(201).json({
        success: true,
        data: answer,
        message: 'Answer created successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get answer by ID
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async getAnswerById(req, res, next) {
    try {
      const { id } = req.params;
      const answer = await answerService.getAnswerById(id);

      res.status(200).json({
        success: true,
        data: answer,
        message: 'Answer retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update answer
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async updateAnswer(req, res, next) {
    try {
      const { id } = req.params;
      const { content } = req.body;
      const userId = req.user.id;

      const answer = await answerService.updateAnswer(id, userId, { content });

      res.status(200).json({
        success: true,
        data: answer,
        message: 'Answer updated successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Delete answer
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async deleteAnswer(req, res, next) {
    try {
      const { id } = req.params;
      const userId = req.user.id;
      const userRole = req.user.role || 'user';

      await answerService.deleteAnswer(id, userId, userRole);

      res.status(200).json({
        success: true,
        message: 'Answer deleted successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mark answer as accepted
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async markAsAccepted(req, res, next) {
    try {
      const { id } = req.params;
      const userId = req.user.id;

      const answer = await answerService.markAsAccepted(id, userId);

      res.status(200).json({
        success: true,
        data: answer,
        message: 'Answer marked as accepted'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Remove accepted status from an answer
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async unmarkAsAccepted(req, res, next) {
    try {
      const { id } = req.params;
      const userId = req.user.id;

      const answer = await answerService.unmarkAsAccepted(id, userId);

      res.status(200).json({
        success: true,
        data: answer,
        message: 'Answer unmarked as accepted'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get answers for a question
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async getAnswersByQuestion(req, res, next) {
    try {
      const { questionId } = req.params;
      const { page = 1, limit = 10, sort = 'votes' } = req.query;

      const answers = await answerService.getAnswersByQuestion(questionId, {
        page: parseInt(page),
        limit: parseInt(limit),
        sort
      });

      res.status(200).json({
        success: true,
        data: answers,
        message: 'Answers retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get answers by user
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async getAnswersByUser(req, res, next) {
    try {
      const { userId } = req.params;
      const { page = 1, limit = 10 } = req.query;

      const answers = await answerService.getAnswersByUser(userId, {
        page: parseInt(page),
        limit: parseInt(limit)
      });

      res.status(200).json({
        success: true,
        data: answers,
        message: 'User answers retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AnswerController();
