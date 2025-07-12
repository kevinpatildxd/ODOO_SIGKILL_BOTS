const Tag = require('../models/Tag');
const Question = require('../models/Question');

class TagService {
  /**
   * Get all tags with pagination and search
   * @param {Object} options - Search options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=50] - Number of tags per page
   * @param {string} [options.search] - Search term
   * @param {string} [options.sort='usage'] - Sort by ('usage', 'name', 'newest')
   * @returns {Promise<Object>} Paginated tags
   */
  async getAllTags(options) {
    try {
      return await Tag.getTags(options);
    } catch (error) {
      throw new Error(`Failed to get tags: ${error.message}`);
    }
  }

  /**
   * Get tag by ID
   * @param {number} id - Tag ID
   * @returns {Promise<Object>} Tag object
   */
  async getTagById(id) {
    try {
      const tag = await Tag.getById(id);
      if (!tag) {
        throw new Error('Tag not found');
      }
      return tag;
    } catch (error) {
      throw new Error(`Failed to get tag: ${error.message}`);
    }
  }

  /**
   * Get tag by name
   * @param {string} name - Tag name
   * @returns {Promise<Object>} Tag object
   */
  async getTagByName(name) {
    try {
      const tag = await Tag.getByName(name);
      if (!tag) {
        throw new Error('Tag not found');
      }
      return tag;
    } catch (error) {
      throw new Error(`Failed to get tag: ${error.message}`);
    }
  }

  /**
   * Create a new tag
   * @param {Object} tagData - Tag data
   * @param {string} tagData.name - Tag name
   * @param {string} [tagData.description] - Tag description
   * @param {string} [tagData.color] - Tag color (hex code)
   * @returns {Promise<Object>} Created tag object
   */
  async createTag(tagData) {
    try {
      return await Tag.create(tagData);
    } catch (error) {
      throw new Error(`Failed to create tag: ${error.message}`);
    }
  }

  /**
   * Update a tag
   * @param {number} id - Tag ID
   * @param {Object} tagData - Tag data to update
   * @param {string} [tagData.name] - Tag name
   * @param {string} [tagData.description] - Tag description
   * @param {string} [tagData.color] - Tag color (hex code)
   * @returns {Promise<Object>} Updated tag object
   */
  async updateTag(id, tagData) {
    try {
      return await Tag.update(id, tagData);
    } catch (error) {
      throw new Error(`Failed to update tag: ${error.message}`);
    }
  }

  /**
   * Delete a tag
   * @param {number} id - Tag ID
   * @returns {Promise<boolean>} True if tag was deleted
   */
  async deleteTag(id) {
    try {
      return await Tag.delete(id);
    } catch (error) {
      throw new Error(`Failed to delete tag: ${error.message}`);
    }
  }

  /**
   * Get tags for a question
   * @param {number} questionId - Question ID
   * @returns {Promise<Array<Object>>} Array of tags
   */
  async getTagsForQuestion(questionId) {
    try {
      return await Tag.getTagsForQuestion(questionId);
    } catch (error) {
      throw new Error(`Failed to get tags for question: ${error.message}`);
    }
  }

  /**
   * Get popular tags
   * @param {number} limit - Maximum number of tags to return
   * @returns {Promise<Array<Object>>} Array of popular tags
   */
  async getPopularTags(limit = 20) {
    try {
      return await Tag.getPopularTags(limit);
    } catch (error) {
      throw new Error(`Failed to get popular tags: ${error.message}`);
    }
  }

  /**
   * Search tags (for autocomplete)
   * @param {string} query - Search query
   * @param {number} limit - Maximum number of results to return
   * @returns {Promise<Array<Object>>} Array of matching tags
   */
  async searchTags(query, limit = 10) {
    try {
      // Using DB query directly for this specific search functionality
      const db = require('../config/database');
      
      const result = await db.query(
        `SELECT id, name, description, color, usage_count 
         FROM tags 
         WHERE name ILIKE $1
         ORDER BY usage_count DESC, name ASC
         LIMIT $2`,
        [`%${query}%`, limit]
      );
      
      return result.rows;
    } catch (error) {
      throw new Error(`Failed to search tags: ${error.message}`);
    }
  }

  /**
   * Add tags to a question
   * @param {number} questionId - Question ID
   * @param {Array<string>} tagNames - Array of tag names
   * @returns {Promise<Array<Object>>} Array of added tags
   */
  async addTagsToQuestion(questionId, tagNames) {
    try {
      return await Tag.addTagsToQuestion(questionId, tagNames);
    } catch (error) {
      throw new Error(`Failed to add tags to question: ${error.message}`);
    }
  }

  /**
   * Remove a tag from a question
   * @param {number} questionId - Question ID
   * @param {number} tagId - Tag ID
   * @returns {Promise<boolean>} True if tag was removed
   */
  async removeTagFromQuestion(questionId, tagId) {
    try {
      return await Tag.removeTagFromQuestion(questionId, tagId);
    } catch (error) {
      throw new Error(`Failed to remove tag from question: ${error.message}`);
    }
  }

  /**
   * Update tag associations for a question
   * @param {number} questionId - Question ID
   * @param {Array<string>} tagNames - Array of tag names
   * @returns {Promise<Array>} Array of associated tags
   */
  async updateQuestionTags(questionId, tagNames) {
    try {
      // Verify question exists
      const question = await Question.getById(questionId);
      if (!question) {
        throw new Error('Question not found');
      }

      // Get current tags
      const currentTags = await Tag.getTagsForQuestion(questionId);
      const currentTagNames = currentTags.map(tag => tag.name.toLowerCase());
      
      // Find tags to add (new tags not in current tags)
      const tagsToAdd = tagNames.filter(name => 
        !currentTagNames.includes(name.toLowerCase())
      );
      
      // Find tags to remove (current tags not in new tags)
      const tagsToRemove = currentTags.filter(tag => 
        !tagNames.map(name => name.toLowerCase()).includes(tag.name.toLowerCase())
      );
      
      // Add new tags
      if (tagsToAdd.length > 0) {
        await Tag.addTagsToQuestion(questionId, tagsToAdd);
      }
      
      // Remove old tags
      for (const tag of tagsToRemove) {
        await Tag.removeTagFromQuestion(questionId, tag.id);
      }
      
      // Get updated tags
      const updatedTags = await Tag.getTagsForQuestion(questionId);
      return updatedTags;
    } catch (error) {
      throw new Error(`Failed to update question tags: ${error.message}`);
    }
  }

  /**
   * Search questions by tag
   * @param {string} tagName - Tag name
   * @param {Object} options - Pagination options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=10] - Questions per page
   * @returns {Promise<Object>} Paginated questions
   */
  async searchQuestionsByTag(tagName, options = {}) {
    try {
      // Verify tag exists
      const tag = await Tag.getByName(tagName);
      if (!tag) {
        throw new Error('Tag not found');
      }

      // Get questions with this tag
      return await Question.getQuestionsByTag(tagName, options);
    } catch (error) {
      throw new Error(`Failed to search questions by tag: ${error.message}`);
    }
  }
}

module.exports = new TagService();
