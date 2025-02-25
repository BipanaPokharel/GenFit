require("dotenv").config();
const app = require("./app");
const { initializeDatabase } = require("./config/dbINIT");
const { sequelize } = require("./config/dbINIT"); // Import sequelize instance
const http = require('http'); // Import http module
const initSocket = require('./socket'); // Import the socket initialization function

const PORT = process.env.PORT || 3000;

(async () => {
  try {
    // Initialize database connection
    const dbInitialized = await initializeDatabase();
    if (!dbInitialized) {
      throw new Error("Failed to initialize database");
    }

    // Sync the database
    await sequelize.sync({ alter: true });

    // Create an HTTP server to integrate with socket.io
    const server = http.createServer(app);

    // Initialize socket.io with the server
    initSocket(server);

    // Start the server
    server.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error("Error starting server:", error);
  }
})();
