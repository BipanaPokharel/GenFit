const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/dbINIT');

const Post = sequelize.define('Post', {
  post_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'user', 
      key: 'user_id'
    }
  },
  title: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  image: {
    type: DataTypes.STRING(255)
  },
  created_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  },
  updated_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  }
}, {
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  tableName: 'posts',
  underscored: true,
  indexes: [
    {
      fields: ['user_id']
    }
  ]
});

// Associations
Post.associate = (models) => {
  Post.belongsTo(models.User, {
    foreignKey: 'user_id',
    as: 'author'
  });

  Post.hasMany(models.Comment, {
    foreignKey: 'post_id',
    as: 'comments',
    onDelete: 'CASCADE'
  });

  Post.hasMany(models.Reaction, {
    foreignKey: 'post_id',
    as: 'reactions',
    onDelete: 'CASCADE'
  });
};

module.exports = Post;