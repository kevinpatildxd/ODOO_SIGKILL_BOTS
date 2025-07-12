/**
 * Tag Controller
 * Handles HTTP requests related to tags
 */
const tagService = require('../services/tagService');
const { HTTP_STATUS } = require('../utils/constants');

class TagController {
  /**
   * Get all tags with pagination and search
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getAllTags(req, res, next) {
    try {
      const { page = 1, limit = 50, search = '', sort = 'usage' } = req.query;

      const result = await tagService.getAllTags({
        page: parseInt(page),
        limit: parseInt(limit),
        search,
        sort
      });

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Tags retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get tag by ID
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getTagById(req, res, next) {
    try {
      const { id } = req.params;
      const result = await tagService.getTagById(parseInt(id));

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Tag retrieved successfully'
      });
    } catch (error) {
      if (error.message === 'Tag not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Tag not found'
        });
      }
      next(error);
    }
  }

  /**
   * Create a new tag
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async createTag(req, res, next) {
    try {
      const { name, description, color } = req.body;
      const result = await tagService.createTag({ name, description, color });

      res.status(HTTP_STATUS.CREATED).json({
        success: true,
        data: result,
        message: 'Tag created successfully'
      });
    } catch (error) {
      if (error.message === 'Tag already exists') {
        return res.status(HTTP_STATUS.CONFLICT).json({
          success: false,
          message: 'Tag already exists'
        });
      }
      next(error);
    }
  }

  /**
   * Update a tag
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async updateTag(req, res, next) {
    try {
      const { id } = req.params;
      const { name, description, color } = req.body;
      
      // Check if user is admin (only admins can update tags)
      if (req.user.role !== 'admin') {
        return res.status(HTTP_STATUS.FORBIDDEN).json({
          success: false,
          message: 'Only administrators can update tags'
        });
      }

      const result = await tagService.updateTag(parseInt(id), {
        name,
        description,
        color
      });

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Tag updated successfully'
      });
    } catch (error) {
      if (error.message === 'Tag not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Tag not found'
        });
      }
      if (error.message === 'Tag name already exists') {
        return res.status(HTTP_STATUS.CONFLICT).json({
          success: false,
          message: 'Tag name already exists'
        });
      }
      next(error);
    }
  }

  /**
   * Delete a tag
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async deleteTag(req, res, next) {
    try {
      const { id } = req.params;
      
      // Check if user is admin (only admins can delete tags)
      if (req.user.role !== 'admin') {
        return res.status(HTTP_STATUS.FORBIDDEN).json({
          success: false,
          message: 'Only administrators can delete tags'
        });
      }

      await tagService.deleteTag(parseInt(id));

      res.status(HTTP_STATUS.OK).json({
        success: true,
        message: 'Tag deleted successfully'
      });
    } catch (error) {
      if (error.message === 'Tag not found') {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          message: 'Tag not found'
        });
      }
      next(error);
    }
  }

  /**
   * Get popular tags
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getPopularTags(req, res, next) {
    try {
      const { limit = 20 } = req.query;
      const result = await tagService.getPopularTags(parseInt(limit));

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Popular tags retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Search tags (for autocomplete)
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async searchTags(req, res, next) {
    try {
      const { query, limit = 10 } = req.query;
      
      if (!query || query.trim().length < 2) {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          success: false,
          message: 'Search query must be at least 2 characters'
        });
      }

      const result = await tagService.searchTags(query.trim(), parseInt(limit));

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Tags retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get tags for a specific question
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getTagsForQuestion(req, res, next) {
    try {
      const { questionId } = req.params;
      const result = await tagService.getTagsForQuestion(parseInt(questionId));

      res.status(HTTP_STATUS.OK).json({
        success: true,
        data: result,
        message: 'Question tags retrieved successfully'
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new TagController();
