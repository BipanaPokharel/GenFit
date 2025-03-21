const express = require('express');
const router = express.Router();
const mealController = require('../controllers/mealController');

router.post('/suggestions', mealController.getMealSuggestions);

module.exports = router;