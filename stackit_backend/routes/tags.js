/**
 * Tag routes
 */
const express = require('express');
const tagController = require('../controllers/tagController');
const { authenticate } = require('../middleware/auth');
const { validateTag } = require('../middleware/validation');
const { apiLimiter } = require('../middleware/rateLimit');

const router = express.Router();

// Get all tags with pagination and search
// Public route - no authentication required
router.get('/', apiLimiter, tagController.getAllTags);

// Get popular tags
// Public route - no authentication required
router.get('/popular', apiLimiter, tagController.getPopularTags);

// Search tags (for autocomplete)
// Public route - no authentication required
router.get('/search', apiLimiter, tagController.searchTags);

// Get tags for a specific question
// Public route - no authentication required
router.get('/question/:questionId', apiLimiter, tagController.getTagsForQuestion);

// Get tag by ID
// Public route - no authentication required
router.get('/:id', apiLimiter, tagController.getTagById);

// Create a new tag
// Protected route - authentication required
router.post(
  '/',
  authenticate,
  apiLimiter,
  validateTag.create,
  tagController.createTag
);

// Update a tag
// Protected route - authentication required, admin only
router.put(
  '/:id',
  authenticate,
  apiLimiter,
  validateTag.create,
  tagController.updateTag
);

// Delete a tag
// Protected route - authentication required, admin only
router.delete(
  '/:id',
  authenticate,
  apiLimiter,
  tagController.deleteTag
);

module.exports = router;
