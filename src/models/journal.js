// models/journal.js
const { sequelize } = require("../config/dbINIT");
const { DataTypes } = require("sequelize");

const Journal = sequelize.define("Journal", {
  // Define the attributes of the journal model
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  mood: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
});

module.exports = Journal;
