require("dotenv").config();
const { Sequelize } = require("sequelize");

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    dialect: "postgres",
    logging: false, 
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  }
);

const initializeDatabase = async () => {
  try {
    await sequelize.authenticate();
    console.log("Database connection established.");
    await sequelize.sync({ alter: false }); // Prevent altering existing schema
    console.log("Database models synchronized.");
    return true;
  } catch (error) {
    console.error("Unable to connect to the database:", error);
    return false;
  }
};

module.exports = { sequelize, initializeDatabase };
