require("dotenv").config();
const app = require("./app");
const { initializeDatabase } = require("./config/dbINIT"); // Updated path to match the actual file location

const PORT = process.env.PORT || 3000;

(async () => {
  try {
    const dbInitialized = await initializeDatabase();
    if (!dbInitialized) {
      throw new Error("Failed to initialize database");
    }

    app.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error("Error starting server:", error);
  }
})();
