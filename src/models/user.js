const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/dbINIT"); // Correct import

const User = sequelize.define(
  "User",
  {
    user_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    profile_pic: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    fitness_goal: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  },
  {
    tableName: "User",
    timestamps: false,
  }
);

module.exports = User;
