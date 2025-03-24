const Comment = require('../models/comment');

exports.createComment = async (req, res) => {
  try {
    const { post_id, user_id, content } = req.body;
    
    if (!post_id || !user_id || !content) {
      return res.status(400).json({ 
        success: false,
        error: 'post_id, user_id, and content are required' 
      });
    }

    const comment = await Comment.create({ post_id, user_id, content });
    res.status(201).json({ success: true, data: comment });
  } catch (error) {
    res.status(400).json({ 
      success: false,
      error: `Error creating comment: ${error.message}` 
    });
  }
};

exports.deleteComment = async (req, res) => {
  try {
    const comment = await Comment.findByPk(req.params.id);
    
    if (!comment) {
      return res.status(404).json({ 
        success: false,
        error: 'Comment not found' 
      });
    }

    if (comment.user_id !== req.body.user_id) {
      return res.status(403).json({ 
        success: false,
        error: 'Unauthorized to delete this comment' 
      });
    }

    await comment.destroy();
    res.status(204).end();
  } catch (error) {
    res.status(500).json({ 
      success: false,
      error: `Error deleting comment: ${error.message}` 
    });
  }
};