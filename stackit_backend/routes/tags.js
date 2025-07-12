/**
 * Tag routes
 */
const express = require('express');
const tagController = {
  getAllTags: (req, res) => res.json({ success: true }),
  getPopularTags: (req, res) => res.json({ success: true }),
  getTagByName: (req, res) => res.json({ success: true }),
  searchTags: (req, res) => res.json({ success: true }),
  getTagQuestions: (req, res) => res.json({ success: true }),
  createTag: (req, res) => res.json({ success: true }),
  updateTag: (req, res) => res.json({ success: true }),
  mergeTags: (req, res) => res.json({ success: true }),
  deleteTag: (req, res) => res.json({ success: true })
};
const router = express.Router();

// GET routes for testing only
router.get('/', (req, res) => tagController.getAllTags(req, res));
router.get('/popular', (req, res) => tagController.getPopularTags(req, res));
router.get('/search/:query', (req, res) => tagController.searchTags(req, res));
router.get('/:name', (req, res) => tagController.getTagByName(req, res));
router.get('/:name/questions', (req, res) => tagController.getTagQuestions(req, res));

// POST/PUT/DELETE routes - mock responses for testing
router.post('/', (req, res) => tagController.createTag(req, res));
router.put('/:name', (req, res) => tagController.updateTag(req, res));
router.post('/merge', (req, res) => tagController.mergeTags(req, res));
router.delete('/:name', (req, res) => tagController.deleteTag(req, res));

module.exports = router;
