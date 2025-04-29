// controllers/CommentsController.js
const { Comment, Post, User } = require('../models');

exports.createComment = async (req, res) => {
  try {
    const { post_id, user_id, content } = req.body;
    
    // Validate required fields
    if (!post_id || !user_id || !content) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields'
      });
    }
    
    // Verify post exists
    const post = await Post.findByPk(post_id);
    if (!post) {
      return res.status(404).json({
        success: false,
        error: 'Post not found'
      });
    }
    
    // Create comment
    const comment = await Comment.create({
      post_id,
      user_id,
      content
    });
    
    // Get full comment with user info
    const fullComment = await Comment.findByPk(comment.comment_id, {
      include: [
        {
          model: User,
          attributes: ['user_id', 'username', 'profile_picture']
        }
      ]
    });
    
    res.status(201).json({
      success: true,
      comment: fullComment
    });
  } catch (error) {
    console.error('Error creating comment:', error);
    res.status(500).json({
      success: false,
      error: `Server error: ${error.message}`
    });
  }
};

exports.getCommentsByPostId = async (req, res) => {
  try {
    const { postId } = req.params;
    
    // Verify post exists
    const post = await Post.findByPk(postId);
    if (!post) {
      return res.status(404).json({
        success: false,
        error: 'Post not found'
      });
    }
    
    const comments = await Comment.findAll({
      where: { post_id: postId },
      include: [
        {
          model: User,
          attributes: ['user_id', 'username', 'profile_picture']
        }
      ],
      order: [['created_at', 'ASC']]
    });
    
    res.status(200).json({
      success: true,
      comments
    });
  } catch (error) {
    console.error('Error fetching comments:', error);
    res.status(500).json({
      success: false,
      error: `Server error: ${error.message}`
    });
  }
};

exports.deleteComment = async (req, res) => {
  try {
    const { id } = req.params;
    const { user_id } = req.body; // To verify comment ownership
    
    const comment = await Comment.findByPk(id);
    
    if (!comment) {
      return res.status(404).json({
        success: false,
        error: 'Comment not found'
      });
    }
    
    // Check ownership
    if (comment.user_id !== parseInt(user_id)) {
      return res.status(403).json({
        success: false,
        error: 'You do not have permission to delete this comment'
      });
    }
    
    await comment.destroy();
    
    res.status(200).json({
      success: true,
      message: 'Comment deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting comment:', error);
    res.status(500).json({
      success: false,
      error: `Server error: ${error.message}`
    });
  }
};