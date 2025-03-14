const express = require("express");
const app = express();
const signupRoutes = require("./routes/signupRoutes");
const loginRoutes = require("./routes/loginRoutes");
const forgetPasswordRoutes = require("./routes/forgetPasswordRoutes");
const userRoutes = require("./routes/userRoutes");
const journalRoutes = require("./routes/journalRoutes");
const workoutRoutes = require("./routes/workoutRoutes");
const friendRequestRoutes = require("./routes/friendRequestRoutes");
const chatRoutes = require("./routes/chatRoutes");


// Middleware to parse JSON bodies
app.use(express.json());

// Use routes
app.use("/api/signup", signupRoutes);
app.use("/api/login", loginRoutes);
app.use("/api/forgot-password", forgetPasswordRoutes);
app.use("/api/user", userRoutes);
app.use("/api/journal", journalRoutes);
app.use("/api/workouts", workoutRoutes); 
app.use("/api/friend-requests", friendRequestRoutes);
app.use("/api/chat", chatRoutes);

// Debug log to check if routes are registered
app._router.stack.forEach(function (r) {
  if (r.route && r.route.path) {
    console.log(r.route.path); 
  }
});


module.exports = app;
