const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/dbINIT');

const Comment = sequelize.define('Comment', {
  comment_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  post_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'posts',
      key: 'post_id'
    }
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users', // Make sure you have a User model
      key: 'user_id'
    }
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'comments',
  underscored: true,
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false // No updated_at column in your schema
});

Comment.associate = (models) => {
  Comment.belongsTo(models.Post, {
    foreignKey: 'post_id',
    onDelete: 'CASCADE'
  });
  Comment.belongsTo(models.User, {
    foreignKey: 'user_id'
  });
};

module.exports = Comment;