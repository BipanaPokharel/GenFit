require("dotenv").config();
const app = require("./app");
const { initializeDatabase } = require("./config/dbINIT");
const { sequelize } = require("./config/dbINIT");
const http = require('http');
const initSocket = require('./socket');
const mealRoutes = require("./utils/api"); // Corrected path
const cors = require('cors'); 

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

    // Enable CORS
    app.use(cors());

    // Mount routes
    app.use("/api", mealRoutes);

    // 404 handler
    app.use((req, res) => {
      res.status(404).json({ message: "Not Found" });
    });

    // Global error handler
    app.use((err, req, res, next) => {
      console.error(err.stack);
      res.status(500).json({ message: "Internal server error", error: err.message });
    });

    server.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error("Error starting server:", error);
  }
})();
