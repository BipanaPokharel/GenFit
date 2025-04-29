const User = require('./user');
const Post = require('./post');
const Comment = require('./comment');
const Reaction = require('./reaction'); 

// Define associations
Post.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'author'
});

Post.hasMany(Comment, {
  foreignKey: 'post_id',
  as: 'comments',
  onDelete: 'CASCADE'
});

Post.hasMany(Reaction, {
  foreignKey: 'post_id',
  as: 'reactions',
  onDelete: 'CASCADE'
});

Comment.belongsTo(Post, {
  foreignKey: 'post_id',
  onDelete: 'CASCADE'
});

Comment.belongsTo(User, {
  foreignKey: 'user_id'
});

// Export all models
module.exports = {
  User,
  Post,
  Comment,
  Reaction
};