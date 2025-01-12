const sequelize = require('./database');
const User = require('../models/user');

const initializeDatabase = async () => {
    try {
        await sequelize.authenticate();
        console.log('Database connection established.');
        
        // Sync all models
        await sequelize.sync({ alter: true });
        console.log('Database models synchronized.');
        
        return true;
    } catch (error) {
        console.error('Database initialization error:', error);
        return false;
    }
};

module.exports = { initializeDatabase };