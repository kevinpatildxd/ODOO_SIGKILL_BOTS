/**
 * Question routes
 */
const express = require('express');
const questionController = require('../controllers/questionController');
const { authenticate } = require('../middleware/auth');
const { validateQuestion } = require('../middleware/validation');
const { apiLimiter } = require('../middleware/rateLimit');

const router = express.Router();

// Get all questions with pagination, search, and filtering
// Public route - no authentication required
router.get('/', apiLimiter, questionController.getAllQuestions);

// Get a question by ID
// Public route - no authentication required
router.get('/id/:id', apiLimiter, questionController.getQuestionById);

// Get a question by slug
// Public route - no authentication required
router.get('/slug/:slug', apiLimiter, questionController.getQuestionBySlug);

// Get questions by a specific tag
// Public route - no authentication required
router.get('/tag/:tag', apiLimiter, questionController.getQuestionsByTag);

// Get questions by a specific user
// Public route - no authentication required
router.get('/user/:userId', apiLimiter, questionController.getQuestionsByUser);

// Create a new question
// Protected route - authentication required
router.post(
  '/',
  authenticate,
  apiLimiter,
  validateQuestion.create,
  questionController.createQuestion
);

// Update a question
// Protected route - authentication required
router.put(
  '/:id',
  authenticate,
  apiLimiter,
  validateQuestion.update,
  questionController.updateQuestion
);

// Delete a question
// Protected route - authentication required
router.delete(
  '/:id',
  authenticate,
  apiLimiter,
  questionController.deleteQuestion
);

// Accept an answer for a question
// Protected route - authentication required
router.post(
  '/:questionId/accept/:answerId',
  authenticate,
  apiLimiter,
  questionController.acceptAnswer
);

// Unaccept a previously accepted answer
// Protected route - authentication required
router.delete(
  '/:questionId/accept',
  authenticate,
  apiLimiter,
  questionController.unacceptAnswer
);

module.exports = router;
