const axios = require('axios');
const User = require("../models/user");
const bcrypt = require("bcryptjs");
const fs = require("fs");
const path = require("path");

// Create a new user
exports.createUser = async (req, res) => {
    try {
        const { username, email, password } = req.body;

        // Validate existing user
        const existingUser = await User.findOne({
            where: { email },
            attributes: ['user_id']
        });

        if (existingUser) {
            return res.status(400).json({ error: "Email already exists" });
        }

        // Hash password and create user
        const hashedPassword = await bcrypt.hash(password, 10);
        const user = await User.create({
            username,
            email,
            password: hashedPassword
        });

        // Return sanitized user data
        res.status(201).json({
            user_id: user.user_id,
            username: user.username,
            email: user.email,
            profile_pic: user.profile_pic
        });

    } catch (error) {
        console.error("Create User Error:", error);
        res.status(500).json({
            error: "Failed to create user",
            details: error.message
        });
    }
};

// Get all users
exports.getAllUsers = async (req, res) => {
    try {
        const users = await User.findAll({
            attributes: ['user_id', 'username', 'email', 'profile_pic', 'settings']
        });
        res.status(200).json(users);
    } catch (error) {
        console.error("Get Users Error:", error);
        res.status(500).json({ error: "Failed to retrieve users" });
    }
};

// Update user
exports.updateUser = async (req, res) => {
    try {
        const { user_id } = req.params;
        const { username, email, password } = req.body;

        const user = await User.findByPk(user_id);
        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        const updateData = {};
        if (username) updateData.username = username;
        if (email) updateData.email = email;
        if (password) updateData.password = password;

        await user.update(updateData, {
            individualHooks: true
        });

        const updatedUser = await User.findByPk(user_id, {
            attributes: ['user_id', 'username', 'email', 'profile_pic', 'settings']
        });

        res.status(200).json(updatedUser);

    } catch (error) {
        console.error("Update User Error:", error);
        res.status(500).json({
            error: "Failed to update user",
            details: error.message.includes("unique constraint") 
                ? "Username or email already exists" 
                : error.message
        });
    }
};

// Delete user
exports.deleteUser = async (req, res) => {
    try {
        const { user_id } = req.params;
        const user = await User.findByPk(user_id);

        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        // Remove profile picture if exists
        if (user.profile_pic) {
            const rawPath = user.getDataValue('profile_pic');
            const fullPath = path.join(__dirname, '..', rawPath);
            if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath);
        }

        await user.destroy();
        res.status(200).json({ message: "User deleted successfully" });

    } catch (error) {
        console.error("Delete User Error:", error);
        res.status(500).json({ error: "Failed to delete user" });
    }
};

// Update profile picture
exports.updateProfilePicture = async (req, res) => {
    try {
        const { user_id } = req.params;
        
        if (!req.file) {
            return res.status(400).json({ error: "No file uploaded" });
        }

        const user = await User.findByPk(user_id);
        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        // Remove old profile picture
        if (user.profile_pic) {
            const rawPath = user.getDataValue('profile_pic');
            const fullPath = path.join(__dirname, '..', rawPath);
            if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath);
        }

        // Save new path (relative path without domain)
        const relativePath = `/uploads/profile_pics/${req.file.filename}`;
        await user.update({ profile_pic: relativePath });

        res.status(200).json({
            message: "Profile picture updated successfully",
            profile_pic: user.profile_pic // Returns full URL through model getter
        });

    } catch (error) {
        console.error("Profile Picture Error:", error);
        res.status(500).json({
            error: "Failed to update profile picture",
            details: error.message
        });
    }
};

// Update user settings
exports.updateUserSettings = async (req, res) => {
    try {
        const { user_id } = req.params;
        const { settings } = req.body;

        const user = await User.findByPk(user_id);
        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        // Merge existing settings with new ones
        const updatedSettings = { 
            ...user.settings,
            ...settings 
        };

        await user.update({ settings: updatedSettings });

        res.status(200).json({
            message: "Settings updated successfully",
            settings: updatedSettings
        });

    } catch (error) {
        console.error("Settings Update Error:", error);
        res.status(500).json({ 
            error: "Failed to update settings",
            details: error.message
        });
    }
};

// Get pending friend requests
exports.getPendingFriendRequests = async (req, res) => {
    try {
        const pendingRequests = await FriendRequest.findAll({
            where: { status: "pending" },
            include: [{
                model: User,
                as: 'Sender',
                attributes: ['user_id', 'username', 'profile_pic']
            }]
        });

        res.status(200).json(pendingRequests);
    } catch (error) {
        console.error("Friend Requests Error:", error);
        res.status(500).json({ error: "Failed to fetch pending requests" });
    }
};

// Accept friend request
exports.acceptFriendRequest = async (req, res) => {
    try {
        const { requestId } = req.params;
        const request = await FriendRequest.findByPk(requestId);

        if (!request) {
            return res.status(404).json({ error: "Request not found" });
        }

        await request.update({ status: "accepted" });
        res.status(200).json({ message: "Friend request accepted" });

    } catch (error) {
        console.error("Accept Request Error:", error);
        res.status(500).json({ error: "Failed to accept request" });
    }
};

// Reject friend request
exports.rejectFriendRequest = async (req, res) => {
    try {
        const { requestId } = req.params;
        const request = await FriendRequest.findByPk(requestId);

        if (!request) {
            return res.status(404).json({ error: "Request not found" });
        }

        await request.destroy();
        res.status(200).json({ message: "Friend request rejected" });

    } catch (error) {
        console.error("Reject Request Error:", error);
        res.status(500).json({ error: "Failed to reject request" });
    }
};

// Get meal recommendations
exports.getMealRecommendations = async (req, res) => {
    try {
        const { ingredients } = req.body;

        // Call your local API endpoint for meal recommendations
        const response = await axios.post('http://localhost:3000/api/meals/suggestions', {
            ingredients,
        });

        const recommendations = response.data;

        res.status(200).json({ recommendations });
    } catch (error) {
        console.error("Meal Recommendations Error:", error);
        res.status(500).json({ error: "Failed to get recommendations" });
    }
};
