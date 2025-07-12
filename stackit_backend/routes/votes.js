/**
 * Vote Routes
 * All routes related to vote operations
 */
const express = require('express');
const { authenticate } = require('../middleware/auth');
const voteController = require('../controllers/voteController');
const { validateVote } = require('../middleware/validation');
const router = express.Router();

// Create or update a vote
router.post('/', authenticate, validateVote, voteController.vote);

// Get user's vote on a target
router.get('/user/:targetType/:targetId', authenticate, voteController.getUserVote);

// Remove a vote
router.delete('/:targetType/:targetId', authenticate, voteController.removeVote);

// Get vote counts for a target
router.get('/count/:targetType/:targetId', voteController.getVoteCounts);

module.exports = router;
