const express = require("express");
const app = express();
const postsRouter = require('./routes/postRoutes');
const signupRoutes = require("./routes/signupRoutes");
const loginRoutes = require("./routes/loginRoutes");
const forgetPasswordRoutes = require("./routes/forgetPasswordRoutes");
const userRoutes = require("./routes/userRoutes");
const journalRoutes = require("./routes/journalRoutes");
const workoutRoutes = require("./routes/workoutRoutes");
const friendRequestRoutes = require("./routes/friendRequestRoutes");
const chatRoutes = require("./routes/chatRoutes");
const mealRoutes = require("./utils/api");
const cors = require('cors');

// Middleware to parse JSON bodies
app.use(express.json());
app.use(cors());

// Use routes
app.use("/api/posts", postsRouter);
app.use("/api", mealRoutes);
app.use("/api/signup", signupRoutes);
app.use("/api/login", loginRoutes);
app.use("/api/forgot-password", forgetPasswordRoutes);
app.use("/api/user", userRoutes);
app.use("/api/journal", journalRoutes);
app.use("/api/workouts", workoutRoutes); 
app.use("/api/friend-requests", friendRequestRoutes);
app.use("/api/chat", chatRoutes);

// 404 handler
app.use((req, res) => {
    res.status(404).json({ message: "Not Found" });
});

// Global error handler
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: "Internal server error", error: err.message });
});

module.exports = app;
