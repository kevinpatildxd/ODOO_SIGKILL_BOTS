const Tag = require('../models/Tag');
const Question = require('../models/Question');

class TagService {
  /**
   * Create a new tag
   * @param {Object} tagData - Tag data
   * @param {string} tagData.name - Tag name
   * @param {string} [tagData.description] - Tag description
   * @param {string} [tagData.color] - Tag color (hex code)
   * @returns {Promise<Object>} Created tag object
   */
  async createTag(tagData) {
    const { name, description, color } = tagData;

    try {
      // Check if tag already exists
      const existingTag = await Tag.getByName(name);
      if (existingTag) {
        throw new Error('Tag already exists');
      }

      // Create the tag
      const tag = await Tag.create({
        name: name.toLowerCase(),
        description,
        color
      });

      return tag;
    } catch (error) {
      throw new Error(`Failed to create tag: ${error.message}`);
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
   * Update tag
   * @param {number} id - Tag ID
   * @param {Object} tagData - Tag data to update
   * @param {string} [tagData.name] - Tag name
   * @param {string} [tagData.description] - Tag description
   * @param {string} [tagData.color] - Tag color (hex code)
   * @returns {Promise<Object>} Updated tag object
   */
  async updateTag(id, tagData) {
    try {
      // Verify tag exists
      const tag = await Tag.getById(id);
      if (!tag) {
        throw new Error('Tag not found');
      }

      // If name is being updated, check if it already exists
      if (tagData.name && tagData.name !== tag.name) {
        const existingTag = await Tag.getByName(tagData.name);
        if (existingTag && existingTag.id !== id) {
          throw new Error('Tag name already exists');
        }
      }

      // Update the tag
      const updatedTag = await Tag.update(id, tagData);
      return updatedTag;
    } catch (error) {
      throw new Error(`Failed to update tag: ${error.message}`);
    }
  }

  /**
   * Delete tag
   * @param {number} id - Tag ID
   * @returns {Promise<boolean>} True if tag was deleted
   */
  async deleteTag(id) {
    try {
      const deleted = await Tag.delete(id);
      return deleted;
    } catch (error) {
      throw new Error(`Failed to delete tag: ${error.message}`);
    }
  }

  /**
   * Get all tags with pagination and optional search
   * @param {Object} options - Search options
   * @param {number} [options.page=1] - Page number
   * @param {number} [options.limit=50] - Number of tags per page
   * @param {string} [options.search] - Search term
   * @param {string} [options.sort='usage'] - Sort by ('usage', 'name', 'newest')
   * @returns {Promise<Object>} Paginated tags
   */
  async getTags(options = {}) {
    try {
      return await Tag.getTags(options);
    } catch (error) {
      throw new Error(`Failed to get tags: ${error.message}`);
    }
  }

  /**
   * Add tags to a question
   * @param {number} questionId - Question ID
   * @param {Array<string>} tagNames - Array of tag names
   * @returns {Promise<Array>} Array of associated tags
   */
  async addTagsToQuestion(questionId, tagNames) {
    try {
      // Verify question exists
      const question = await Question.getById(questionId);
      if (!question) {
        throw new Error('Question not found');
      }

      // Add tags to the question
      const tags = await Tag.addTagsToQuestion(questionId, tagNames);
      return tags;
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
      // Verify question exists
      const question = await Question.getById(questionId);
      if (!question) {
        throw new Error('Question not found');
      }

      // Verify tag exists
      const tag = await Tag.getById(tagId);
      if (!tag) {
        throw new Error('Tag not found');
      }

      // Remove the tag from the question
      const removed = await Tag.removeTagFromQuestion(questionId, tagId);
      return removed;
    } catch (error) {
      throw new Error(`Failed to remove tag from question: ${error.message}`);
    }
  }

  /**
   * Get tags for a question
   * @param {number} questionId - Question ID
   * @returns {Promise<Array>} Array of tags
   */
  async getTagsForQuestion(questionId) {
    try {
      // Verify question exists
      const question = await Question.getById(questionId);
      if (!question) {
        throw new Error('Question not found');
      }

      // Get tags for the question
      const tags = await Tag.getTagsForQuestion(questionId);
      return tags;
    } catch (error) {
      throw new Error(`Failed to get tags for question: ${error.message}`);
    }
  }

  /**
   * Get popular tags
   * @param {number} [limit=20] - Maximum number of tags to return
   * @returns {Promise<Array>} Array of popular tags
   */
  async getPopularTags(limit = 20) {
    try {
      return await Tag.getPopularTags(limit);
    } catch (error) {
      throw new Error(`Failed to get popular tags: ${error.message}`);
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
