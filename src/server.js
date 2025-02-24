require("dotenv").config();
const app = require("./app");
const { initializeDatabase } = require("./config/dbINIT");
const { sequelize } = require("./config/dbINIT"); // Import sequelize instance

const PORT = process.env.PORT || 3000;

(async () => {
  try {
    // Initialize database connection
    const dbInitialized = await initializeDatabase();
    if (!dbInitialized) {
      throw new Error("Failed to initialize database");
    }

    // Sync the database, creating tables if they don't exist or altering them if needed
    await sequelize.sync({ alter: true }); // Use { force: true } to drop & recreate tables if needed

    // Start the server
    app.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error("Error starting server:", error);
  }
})();
