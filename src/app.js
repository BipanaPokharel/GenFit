// backend/app.js
const express = require("express");
const app = express();
const signupRoutes = require("./routes/signupRoutes");
const loginRoutes = require("./routes/loginRoutes");
const forgetPasswordRoutes = require("./routes/forgetPasswordRoutes");
const userRoutes = require("./routes/userRoutes"); 
const journalRoutes = require("./routes/journalRoutes"); 

// Middleware to parse JSON bodies
app.use(express.json());

app.use("/api/signup", signupRoutes);
app.use("/api/login", loginRoutes);
app.use("/api/forgot-password", forgetPasswordRoutes);
app.use("/api/user", userRoutes); 
app.use("/api/journal", journalRoutes); 

// Debug log to check if routes are registered
app._router.stack.forEach(function (r) {
  if (r.route && r.route.path) {
    console.log(r.route.path);
  }
});

// Error handling
app.use((req, res, next) => {
  res.status(404).json({ message: "Not Found" });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res
    .status(500)
    .json({ message: "Internal server error", error: err.message });
});

module.exports = app;
