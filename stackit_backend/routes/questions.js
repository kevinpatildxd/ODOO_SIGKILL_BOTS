/**
 * Question routes
 */
const express = require('express');
const questionController = {
  getAllQuestions: (req, res) => res.json({ success: true }),
  getPopularQuestions: (req, res) => res.json({ success: true }),
  getRecentQuestions: (req, res) => res.json({ success: true }),
  searchQuestions: (req, res) => res.json({ success: true }),
  getQuestionById: (req, res) => res.json({ success: true }),
  getQuestionsByTag: (req, res) => res.json({ success: true }),
  createQuestion: (req, res) => res.json({ success: true }),
  updateQuestion: (req, res) => res.json({ success: true }),
  deleteQuestion: (req, res) => res.json({ success: true }),
  voteQuestion: (req, res) => res.json({ success: true }),
  getQuestionAnswers: (req, res) => res.json({ success: true }),
  createAnswer: (req, res) => res.json({ success: true }),
  acceptAnswer: (req, res) => res.json({ success: true }),
  getQuestionViewCount: (req, res) => res.json({ success: true }),
  incrementViewCount: (req, res) => res.json({ success: true })
};
const router = express.Router();

// Get routes
router.get('/', (req, res) => questionController.getAllQuestions(req, res));
router.get('/popular', (req, res) => questionController.getPopularQuestions(req, res));
router.get('/recent', (req, res) => questionController.getRecentQuestions(req, res));
router.get('/search', (req, res) => questionController.searchQuestions(req, res));
router.get('/tag/:tagName', (req, res) => questionController.getQuestionsByTag(req, res));
router.get('/:id', (req, res) => questionController.getQuestionById(req, res));
router.get('/:id/answers', (req, res) => questionController.getQuestionAnswers(req, res));
router.get('/:id/views', (req, res) => questionController.getQuestionViewCount(req, res));

// Post/Put/Delete routes
router.post('/', (req, res) => questionController.createQuestion(req, res));
router.put('/:id', (req, res) => questionController.updateQuestion(req, res));
router.delete('/:id', (req, res) => questionController.deleteQuestion(req, res));
router.post('/:id/vote', (req, res) => questionController.voteQuestion(req, res));
router.post('/:id/answers', (req, res) => questionController.createAnswer(req, res));
router.put('/:questionId/answers/:answerId/accept', (req, res) => questionController.acceptAnswer(req, res));
router.post('/:id/views', (req, res) => questionController.incrementViewCount(req, res));

module.exports = router;
