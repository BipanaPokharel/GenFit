const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController.js");

// Route for meal recommendations
router.post("/recommendations", userController.getMealRecommendations);

module.exports = router;
