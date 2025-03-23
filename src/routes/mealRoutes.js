// routes/mealRoutes.js
const express = require('express');
const router = express.Router();
const mealController = require('../controllers/mealController');

// Meal Suggestions
router.post('/suggestions', mealController.getMealSuggestions);

// Meal Plans CRUD
router.post('/meal-plans', mealController.createMealPlan);
router.get('/meal-plans', mealController.getMealPlans);
router.put('/meal-plans/:id', mealController.updateMealPlan);
router.delete('/meal-plans/:id', mealController.deleteMealPlan);

module.exports = router;