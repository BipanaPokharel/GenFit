const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
require('./config/database');

dotenv.config();

const app = express();

// Middleware
const corsOptions = {
    origin: '*', // For development - change this in production
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
};

app.use(cors(corsOptions));
app.use(express.json());

// Routes
app.use('/api/signup', require('./routes/signupRoutes'));
app.use('/api/login', require('./routes/loginRoutes')); // Make sure this path matches

// Error handling
app.use((req, res, next) => {
    res.status(404).json({ message: 'Not Found' });
});

app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Internal server error', error: err.message });
});

module.exports = app;