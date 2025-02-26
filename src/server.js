require("dotenv").config();
const app = require("./app");
const { initializeDatabase } = require("./config/dbINIT");
const { sequelize } = require("./config/dbINIT");
const http = require('http');
const initSocket = require('./socket');

const PORT = process.env.PORT || 3000;

(async () => {
  try {
    const dbInitialized = await initializeDatabase();
    if (!dbInitialized) {
      throw new Error("Failed to initialize database");
    }

    await sequelize.sync({ alter: true }); 

    const server = http.createServer(app);
    initSocket(server);

    server.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error("Error starting server:", error);
  }
})();
