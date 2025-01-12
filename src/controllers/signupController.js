const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const { body, validationResult } = require('express-validator');

exports.validateSignup = [
    body('username').notEmpty().withMessage('Username is required'),
    body('email').isEmail().withMessage('Invalid email address'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
];

exports.signup = async (req, res) => {
    try {
        console.log('Signup request body:', req.body); // Debug log

        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { username, email, password, profile_pic, fitness_goal } = req.body;

        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
            return res.status(400).json({ message: 'User already exists' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const user = await User.create({
            username,
            email,
            password: hashedPassword,
            profile_pic: profile_pic || null,
            fitness_goal: fitness_goal || null
        });

        const token = jwt.sign(
            { userId: user.user_id, email: user.email },
            process.env.JWT_SECRET || 'bipana@!0',
            { expiresIn: '1h' }
        );

        res.status(201).json({
            message: 'User registered successfully',
            user: {
                user_id: user.user_id,
                email: user.email,
                username: user.username
            },
            token
        });
    } catch (error) {
        console.error('Signup error:', error);
        res.status(500).json({
            message: 'Failed to create user',
            error: error.message
        });
    }
};