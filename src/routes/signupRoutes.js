// signupRoutes.js
const express = require('express');
const router = express.Router();
const signupController = require('../controllers/signupController');

// Define the signup route with validation middleware
router.post('/', signupController.validateSignup, signupController.signup); // The route is just '/' here

module.exports = router;
