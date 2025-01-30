const { Sequelize } = require("sequelize");

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    dialect: "postgres",
    logging: false,
  }
);

const initializeDatabase = async () => {
  try {
    await sequelize.authenticate();
    console.log("Database connection established.");
    await sequelize.sync();
    console.log("Database models synchronized.");
    return true;
  } catch (error) {
    console.error("Unable to connect to the database:", error);
    return false;
  }
};

module.exports = { sequelize, initializeDatabase };
