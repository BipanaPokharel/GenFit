// routes/userRoutes.js
const express = require("express");
const router = express.Router();
const { createUser, getAllUsers } = require("../controllers/userController"); // Import controller methods

// Route for creating a user
router.post("/user", createUser);

// Route for fetching all users
router.get("/user", getAllUsers);

module.exports = router;
