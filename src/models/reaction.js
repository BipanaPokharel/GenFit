const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/dbINIT');

const Reaction = sequelize.define('Reaction', {
  reaction_id: {
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
  type: {
    type: DataTypes.STRING(20),
    allowNull: false
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'reactions',
  underscored: true,
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false, // No updated_at column in your schema
  indexes: [{
    unique: true,
    fields: ['post_id', 'user_id']
  }]
});

Reaction.associate = (models) => {
  Reaction.belongsTo(models.Post, {
    foreignKey: 'post_id',
    onDelete: 'CASCADE'
  });
  Reaction.belongsTo(models.User, {
    foreignKey: 'user_id'
  });
};

module.exports = Reaction;