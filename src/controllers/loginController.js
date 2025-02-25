const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/user");

exports.login = async (req, res) => {
  console.log("Login request body:", req.body);

  try {
    const { email, password } = req.body; 

    // Check if user exists in the database
    const user = await User.findOne({ where: { email } });
    console.log("User found:", user); // Debug log

    if (!user) {
      // Check if user exists
      console.log("User not found");
      return res.status(401).json({ message: "Invalid email or password" }); // Return error if not found
    }

    // Compare password using bcryptjs
    const validPassword = await bcrypt.compare(password, user.password);
    console.log("Password valid:", validPassword); // Debug log

    if (!validPassword) {
      // Compare password
      console.log("Invalid password");
      return res.status(401).json({ message: "Invalid email or password" }); // Return error if password is invalid
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.user_id, email: user.email },
      process.env.JWT_SECRET || "bipana@!0",
      { expiresIn: "1h" }
    );

    // Send response with token
    res.status(200).json({
      message: "Login successful",
      user: {
        user_id: user.user_id,
        username: user.username,
        email: user.email,
        profile_pic: user.profile_pic,
        fitness_goal: user.fitness_goal,
      },
      token,
    });
  } catch (error) {
    console.error("Login error:", error); // Log the error for debugging
    console.log("Error details:", error.message); // Log the error message for more context
    res
      .status(500)
      .json({ message: "Internal server error", error: error.message });
  }
};
