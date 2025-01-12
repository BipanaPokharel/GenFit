// controllers/loginController.js
const bcrypt = require('bcryptjs'); // Change from bcrypt to bcryptjs to match signup
const jwt = require('jsonwebtoken');
const User = require('../models/user');

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Check if user exists in the database
        const user = await User.findOne({ where: { email } });

        if (!user) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        // Compare password using bcryptjs
        const validPassword = await bcrypt.compare(password, user.password);

        if (!validPassword) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        // Generate JWT token
        const token = jwt.sign(
            { userId: user.user_id, email: user.email },
            process.env.JWT_SECRET || 'bipana@!0',
            { expiresIn: '1h' }
        );

        // Send response with token
        res.status(200).json({
            message: 'Login successful',
            user: {
                user_id: user.user_id,
                username: user.username,
                email: user.email,
                profile_pic: user.profile_pic,
                fitness_goal: user.fitness_goal
            },
            token
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};