// controllers/userController.js
// Adjust the path if needed

// Create a new user
exports.createUser = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const user = await User.create({ name, email, password });
    res.status(201).json(user); // Respond with created user
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: error.message }); // Send the error message
  }
};

// Get all users
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll(); // Retrieve all users
    res.status(200).json(users); // Send the users data as response
  } catch (error) {
    console.error(error); // Log error
    res.status(500).json({ error: error.message }); // Send error message
  }
};
