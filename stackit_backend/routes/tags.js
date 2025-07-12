/**
 * Tag routes
 */
const express = require('express');
const { authenticate, authorizeAdmin } = require('../middleware/auth');
const { tagSchemas, validateSchema } = require('../middleware/validation');
const { apiLimiter } = require('../middleware/rateLimit');
const tagController = require('../controllers/tagController');
const { cacheMiddleware } = require('../utils/caching');
const router = express.Router();

// Apply rate limiting to all routes in this router
router.use(apiLimiter);

// Get all tags - with longer caching (10 minutes) as tags don't change often
router.get('/', cacheMiddleware(600), tagController.getAllTags);

// Get popular tags - cached for 10 minutes
router.get('/popular', cacheMiddleware(600), tagController.getPopularTags);

// Get a tag by name - cached for 5 minutes
router.get('/:name', cacheMiddleware(300), tagController.getTagByName);

// Search tags - cached but shorter (1 minute) due to search nature
router.get('/search/:query', cacheMiddleware(60), tagController.searchTags);

// Get questions for a specific tag - cached for 2 minutes
router.get('/:name/questions', cacheMiddleware(120), tagController.getTagQuestions);

// Create a new tag - admin only
router.post(
  '/', 
  authenticate, 
  authorizeAdmin,
  validateSchema(tagSchemas.create), 
  tagController.createTag
);

// Update a tag - admin only
router.put(
  '/:name',
  authenticate,
  authorizeAdmin,
  validateSchema(tagSchemas.update),
  tagController.updateTag
);

// Merge tags - admin only
router.post(
  '/merge',
  authenticate,
  authorizeAdmin,
  validateSchema(tagSchemas.merge),
  tagController.mergeTags
);

// Delete a tag - admin only
router.delete(
  '/:name',
  authenticate,
  authorizeAdmin,
  tagController.deleteTag
);

module.exports = router;
