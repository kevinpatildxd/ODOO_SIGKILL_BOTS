/**
 * Answer Routes
 * All routes related to answer operations
 */
const express = require('express');
const { authenticate } = require('../middleware/auth');
const answerController = require('../controllers/answerController');
const { validateAnswer } = require('../middleware/validation');
const router = express.Router();

// Create an answer (requires authentication)
router.post('/', authenticate, validateAnswer.create, answerController.createAnswer);

// Get answer by ID
router.get('/:id', answerController.getAnswerById);

// Update answer (requires authentication and ownership)
router.put('/:id', authenticate, validateAnswer.update, answerController.updateAnswer);

// Delete answer (requires authentication and ownership or admin/moderator role)
router.delete('/:id', authenticate, answerController.deleteAnswer);

// Mark answer as accepted (requires authentication and question ownership)
router.patch('/:id/accept', authenticate, answerController.markAsAccepted);

// Remove accepted status from answer (requires authentication and question ownership)
router.patch('/:id/unaccept', authenticate, answerController.unmarkAsAccepted);

// Get answers for a question
router.get('/question/:questionId', answerController.getAnswersByQuestion);

// Get answers by user
router.get('/user/:userId', answerController.getAnswersByUser);

module.exports = router;
