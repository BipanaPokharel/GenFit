// models/friendRequest.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/dbINIT'); // Adjust this path based on your project structure

const FriendRequest = sequelize.define('FriendRequest', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    sender_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    receiver_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    status: {
        type: DataTypes.STRING,
        allowNull: false,
        validate: {
            isIn: [['pending', 'accepted', 'rejected']]
        }
    },
    created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
    }
}, {
    tableName: 'FriendRequests',
    timestamps: false, 
});

module.exports = FriendRequest;
