const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/user");

exports.login = async (req, res) => {
  console.log("Login request body:", req.body);

  try {
    const { email, password } = req.body;

    // Normalize email
    const normalizedEmail = email.trim().toLowerCase();

    let user;
    try {
      user = await User.findOne({ where: { email: normalizedEmail } });
      console.log("User found:", user);
    } catch (dbError) {
      console.error("Database query error:", dbError);
      return res.status(500).json({ message: "Database error", error: dbError.message });
    }

    if (!user) {
      console.log("User not found");
      return res.status(401).json({ message: "Invalid email or password" });
    }

    const validPassword = await bcrypt.compare(password, user.password);
    console.log("Password valid:", validPassword);

    if (!validPassword) {
      console.log("Invalid password");
      return res.status(401).json({ message: "Invalid email or password" });
    }

    const token = jwt.sign(
      { userId: user.user_id, email: user.email },
      process.env.JWT_SECRET || "bipana@!0",
      { expiresIn: "1h" }
    );

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
    console.error("Login error:", error);
    console.log("Error details:", error.message);
    res.status(500).json({ message: "Internal server error", error: error.message });
  }
};
