/**
 * Question routes
 */
const express = require('express');
const { authenticate } = require('../middleware/auth');
const { questionSchemas, validateSchema } = require('../middleware/validation');
const { apiLimiter } = require('../middleware/rateLimit');
const questionController = require('../controllers/questionController');
const { cacheMiddleware } = require('../utils/caching');
const router = express.Router();

// Apply rate limiting to all routes in this router
router.use(apiLimiter);

// Get all questions (public) - with caching for 2 minutes (120 seconds)
router.get('/', cacheMiddleware(120), questionController.getAllQuestions);

// Get popular questions (public) - with caching for 5 minutes (300 seconds)
router.get('/popular', cacheMiddleware(300), questionController.getPopularQuestions);

// Get recent questions (public) - with caching for 1 minute (60 seconds)
router.get('/recent', cacheMiddleware(60), questionController.getRecentQuestions);

// Search questions (public) - with shorter cache due to dynamic nature
router.get('/search', cacheMiddleware(30), questionController.searchQuestions);

// Get questions by tag (public) - with caching for 3 minutes
router.get('/tag/:tagName', cacheMiddleware(180), questionController.getQuestionsByTag);

// Get question by ID (public) - with caching
router.get('/:id', cacheMiddleware(120), questionController.getQuestionById);

// Create new question (authenticated)
router.post('/', authenticate, validateSchema(questionSchemas.create), questionController.createQuestion);

// Update question (authenticated + authorized)
router.put('/:id', authenticate, validateSchema(questionSchemas.update), questionController.updateQuestion);

// Delete question (authenticated + authorized)
router.delete('/:id', authenticate, questionController.deleteQuestion);

// Vote on question (authenticated)
router.post('/:id/vote', authenticate, validateSchema(questionSchemas.vote), questionController.voteQuestion);

// Get answers for question (public) - with caching
router.get('/:id/answers', cacheMiddleware(120), questionController.getQuestionAnswers);

// Create answer for question (authenticated)
router.post('/:id/answers', authenticate, validateSchema(questionSchemas.createAnswer), questionController.createAnswer);

// Accept an answer (authenticated + authorized)
router.put('/:questionId/answers/:answerId/accept', authenticate, questionController.acceptAnswer);

// Get question view count
router.get('/:id/views', cacheMiddleware(300), questionController.getQuestionViewCount);

// Increment question view count
router.post('/:id/views', questionController.incrementViewCount);

module.exports = router;
