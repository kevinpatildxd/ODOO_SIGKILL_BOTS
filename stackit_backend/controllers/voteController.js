/**
 * Vote Controller
 * Handles all voting-related HTTP requests
 */
const voteService = require('../services/voteService');

class VoteController {
  /**
   * Vote on a question or answer
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async vote(req, res, next) {
    try {
      const { targetType, targetId, voteType } = req.body;
      const userId = req.user.id;

      const result = await voteService.vote(userId, targetType, targetId, voteType);

      res.status(200).json({
        success: true,
        data: result,
        message: 'Vote recorded successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get user's vote on a specific target
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async getUserVote(req, res, next) {
    try {
      const { targetType, targetId } = req.params;
      const userId = req.user.id;

      const vote = await voteService.getUserVote(userId, targetType, targetId);

      res.status(200).json({
        success: true,
        data: vote,
        message: 'User vote retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Remove a vote
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async removeVote(req, res, next) {
    try {
      const { targetType, targetId } = req.params;
      const userId = req.user.id;

      const result = await voteService.removeVote(userId, targetType, targetId);

      res.status(200).json({
        success: true,
        data: result,
        message: 'Vote removed successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get vote counts for a target
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   * @param {NextFunction} next - Express next middleware function
   * @returns {Promise<void>}
   */
  async getVoteCounts(req, res, next) {
    try {
      const { targetType, targetId } = req.params;

      const counts = await voteService.getVoteCounts(targetType, targetId);

      res.status(200).json({
        success: true,
        data: counts,
        message: 'Vote counts retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new VoteController();
