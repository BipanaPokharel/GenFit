const { Sequelize } = require("sequelize");

const sequelize = new Sequelize(
  "FYPdb", // Database name
  "postgres", // Database user
  "Physics@!0", // Database password
  {
    host: "localhost", // Database host
    dialect: "postgres",
  }
);

const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log("Database connection has been established successfully.");
  } catch (error) {
    console.error("Unable to connect to the database:", error);
  }
};

testConnection();
