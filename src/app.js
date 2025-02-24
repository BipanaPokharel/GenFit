const express = require("express");
const app = express();
const signupRoutes = require("./routes/signupRoutes");
const loginRoutes = require("./routes/loginRoutes");
const forgetPasswordRoutes = require("./routes/forgetPasswordRoutes");
const userRoutes = require("./routes/userRoutes");
const journalRoutes = require("./routes/journalRoutes");
const workoutRoutes = require("./routes/workoutRoutes");
const friendRequestRoutes = require("./routes/friendRequestRoutes");


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

// Debug log to check if routes are registered
app._router.stack.forEach(function (r) {
  if (r.route && r.route.path) {
    console.log(r.route.path); 
  }
});

// Error handling for 404
app.use((req, res, next) => {
  res.status(404).json({ message: "Not Found" });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: "Internal server error", error: err.message });
});

module.exports = app;
