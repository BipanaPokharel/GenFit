const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/dbINIT'); 

const Post = sequelize.define('Post', {
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  image: {
    type: DataTypes.STRING(255)
  },
}, {
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  tableName: 'posts'
});

// Associations
Post.associate = function(models) {
  Post.belongsTo(models.User, { foreignKey: 'user_id' });
  Post.hasMany(models.Comment, { foreignKey: 'post_id', onDelete: 'CASCADE' });
  Post.hasMany(models.Reaction, { foreignKey: 'post_id', onDelete: 'CASCADE' });
};

module.exports = Post;
