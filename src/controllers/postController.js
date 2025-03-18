const Post = require('../models/post');


exports.createPost = async (req, res) => {
  try {
    const { title, user_id, content, image } = req.body;
    
    // Validate required fields
    if (!title || !user_id || !content) {
      return res.status(400).json({
        error: 'Title, user_id, and content are required fields'
      });
    }

    const post = await Post.create({
      title,
      user_id,
      content,
      image: image || null
    });

    res.status(201).json(post);
  } catch (error) {
    res.status(400).json({ 
      error: `Error creating post: ${error.message}` 
    });
  }
};

exports.getPostById = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id, {
      include: [
        { 
          model: Comment,
          as: 'comments' 
        },
        { 
          model: Reaction,
          as: 'reactions'
        }
      ]
    });

    if (!post) {
      return res.status(404).json({ 
        error: 'Post not found' 
      });
    }

    res.json(post);
  } catch (error) {
    res.status(500).json({ 
      error: `Error retrieving post: ${error.message}` 
    });
  }
};

exports.updatePost = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);
    
    if (!post) {
      return res.status(404).json({ 
        error: 'Post not found' 
      });
    }

    // Authorization check
    if (post.user_id !== req.body.user_id) {
      return res.status(403).json({ 
        error: 'Unauthorized to update this post' 
      });
    }

    const allowedFields = ['title', 'content', 'image'];
    const updates = {};
    
    // Only allow specific fields to be updated
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    }

    const updatedPost = await post.update(updates);
    res.json(updatedPost);
  } catch (error) {
    res.status(400).json({ 
      error: `Error updating post: ${error.message}` 
    });
  }
};

exports.deletePost = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);
    
    if (!post) {
      return res.status(404).json({ 
        error: 'Post not found' 
      });
    }

    // Authorization check
    if (post.user_id !== req.body.user_id) {
      return res.status(403).json({ 
        error: 'Unauthorized to delete this post' 
      });
    }

    await post.destroy();
    res.status(204).end();
  } catch (error) {
    res.status(500).json({ 
      error: `Error deleting post: ${error.message}` 
    });
  }
};