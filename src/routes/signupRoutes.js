const express = require("express");
const router = express.Router();
const signupController = require("../controllers/signupController");

// Define the signup route with middleware
router.post("/", signupController.validateSignup, signupController.signup); 

module.exports = router;
