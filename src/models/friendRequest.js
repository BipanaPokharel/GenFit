const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/dbINIT");
const User = require("./user"); 

const FriendRequest = sequelize.define(
  "FriendRequest",
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
        model: "User", 
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
    status: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        isIn: [["pending", "accepted", "rejected"]],
      },
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "FriendRequests",
    timestamps: false,
  }
);

// Define relationships
User.hasMany(FriendRequest, { foreignKey: "sender_id", as: "sentRequests" });
User.hasMany(FriendRequest, { foreignKey: "receiver_id", as: "receivedRequests" });
FriendRequest.belongsTo(User, { foreignKey: "sender_id", as: "sender" });
FriendRequest.belongsTo(User, { foreignKey: "receiver_id", as: "receiver" });

module.exports = FriendRequest;
