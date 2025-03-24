const express = require('express');
const router = express.Router();
const reactionController = require('../controllers/reactionController');

router.post('/', reactionController.addReaction);
router.delete('/:postId', reactionController.removeReaction);

module.exports = router;