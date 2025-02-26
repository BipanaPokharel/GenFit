const User = require("../models/user");
const bcrypt = require("bcryptjs");

// Create a new user
exports.createUser = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({ username, email, password: hashedPassword });
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

// Update a user
exports.updateUser = async (req, res) => {
  try {
    const { user_id } = req.params;
    const { username, email, password } = req.body;
    if (password) {
      const hashedPassword = await bcrypt.hash(password, 10);
      await User.update({ username, email, password: hashedPassword }, {
        where: { user_id },
      });
    } else {
      await User.update({ username, email }, {
        where: { user_id },
      });
    }
    res.status(200).json({ message: "User updated successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

// Delete a user
exports.deleteUser = async (req, res) => {
  try {
    const { user_id } = req.params;
    await User.destroy({ where: { user_id } });
    res.status(200).json({ message: "User deleted successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

// Update user profile picture
exports.updateProfilePicture = async (req, res) => {
  try {
    const { user_id } = req.params;
    const file = req.file;
    if (!file) {
      return res.status(400).json({ error: "No file uploaded" });
    }
    const filePath = file.path;
    await User.update({ profile_pic: filePath }, { where: { user_id } });
    res.status(200).json({ message: "Profile picture updated successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

// Get pending friend requests
exports.getPendingFriendRequests = async (req, res) => {
  try {
    // Assuming you have a Chats model for friend requests
    const pendingRequests = await Chats.findAll({
      where: { status: "pending" },
    });
    res.status(200).json(pendingRequests);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

// Accept friend request
exports.acceptFriendRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    await Chats.update({ status: "accepted" }, { where: { id: requestId } });
    res.status(200).json({ message: "Friend request accepted" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

// Reject friend request
exports.rejectFriendRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    await Chats.update({ status: "rejected" }, { where: { id: requestId } });
    res.status(200).json({ message: "Friend request rejected" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

// Get meal recommendations
exports.getMealRecommendations = async (req, res) => {
  try {
    const { ingredients } = req.body;
    const recommendations = await ApiService.fetchMealRecommendations(ingredients);
    res.status(200).json({ recommendations });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};
