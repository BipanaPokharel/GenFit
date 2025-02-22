const express = require('express');
const router = express.Router();
const journalController = require('../controllers/journalController');


// GET all journal entries
router.get('/', journalController.getAllEntries);

// POST a new journal entry
router.post('/', journalController.addEntry);

// PUT (update) a journal entry by ID
router.put('/:id', journalController.updateEntry);

// DELETE a journal entry by ID
router.delete('/:id', journalController.deleteEntry);

module.exports = router;
