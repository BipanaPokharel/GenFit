const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/dbINIT");
const User = require("./user");

const Chat = sequelize.define(
  "Chat",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    sender_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "User",  // Refers to the User table
        key: "user_id",
      },
    },
    receiver_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "User",
        key: "user_id",
      },
    },
    message: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "Chats",
    timestamps: false,
  }
);

// Define relationships
User.hasMany(Chat, { foreignKey: "sender_id", as: "sentMessages" });
User.hasMany(Chat, { foreignKey: "receiver_id", as: "receivedMessages" });
Chat.belongsTo(User, { foreignKey: "sender_id", as: "sender" });
Chat.belongsTo(User, { foreignKey: "receiver_id", as: "receiver" });

module.exports = Chat;
