require('dotenv').config();
const app = require('./app');
const { initializeDatabase } = require('./config/dbInit');

const PORT = process.env.PORT || 3000;

const startServer = async () => {
    try {
        const dbInitialized = await initializeDatabase();
        if (!dbInitialized) {
            throw new Error('Failed to initialize database');
        }

        app.listen(PORT, () => {
            console.log(`Server running on http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error('Server startup error:', error);
        process.exit(1);
    }
};

startServer();