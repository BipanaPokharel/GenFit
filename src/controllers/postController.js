const Post = require('../models/post');
const Comment = require('../models/comment');
const Reaction = require('../models/reaction');

exports.getAllPosts = async (req, res) => {
  try {
    const posts = await Post.findAll({
      include: [
        { 
          model: Comment,
          as: 'comments',
          attributes: ['comment_id', 'content', 'created_at', 'user_id']
        },
        { 
          model: Reaction,
          as: 'reactions',
          attributes: ['reaction_id', 'type', 'created_at', 'user_id']
        }
      ],
      order: [['created_at', 'DESC']]
    });

    res.status(200).json({
      success: true,
      count: posts.length,
      data: posts
    });
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({
      success: false,
      error: `Server error: ${error.message}`
    });
  }
};

exports.createPost = async (req, res) => {
  try {
    const { title, user_id, content, image } = req.body;
    
    if (!title || !user_id || !content) {
      return res.status(400).json({
        success: false,
        error: 'Title, user_id, and content are required fields'
      });
    }

    const post = await Post.create({
      title,
      user_id,
      content,
      image: image || null
    });

    res.status(201).json({
      success: true,
      data: post
    });
  } catch (error) {
    res.status(400).json({ 
      success: false,
      error: `Validation error: ${error.message}` 
    });
  }
};

exports.getPostById = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id, {
      include: [
        { 
          model: Comment,
          as: 'comments',
          attributes: ['comment_id', 'content', 'created_at', 'user_id']
        },
        { 
          model: Reaction,
          as: 'reactions',
          attributes: ['reaction_id', 'type', 'created_at', 'user_id']
        }
      ]
    });

    if (!post) {
      return res.status(404).json({ 
        success: false,
        error: 'Post not found' 
      });
    }

    res.status(200).json({
      success: true,
      data: post
    });
  } catch (error) {
    res.status(500).json({ 
      success: false,
      error: `Server error: ${error.message}` 
    });
  }
};

exports.updatePost = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);
    
    if (!post) {
      return res.status(404).json({ 
        success: false,
        error: 'Post not found' 
      });
    }

    if (post.user_id !== req.body.user_id) {
      return res.status(403).json({ 
        success: false,
        error: 'Unauthorized to update this post' 
      });
    }

    const allowedFields = ['title', 'content', 'image'];
    const updates = {};
    
    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    const updatedPost = await post.update(updates);
    
    res.status(200).json({
      success: true,
      data: updatedPost
    });
  } catch (error) {
    res.status(400).json({ 
      success: false,
      error: `Update error: ${error.message}` 
    });
  }
};

exports.deletePost = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);
    
    if (!post) {
      return res.status(404).json({ 
        success: false,
        error: 'Post not found' 
      });
    }

    if (post.user_id !== req.body.user_id) {
      return res.status(403).json({ 
        success: false,
        error: 'Unauthorized to delete this post' 
      });
    }

    await post.destroy();
    res.status(204).end();
  } catch (error) {
    res.status(500).json({ 
      success: false,
      error: `Deletion error: ${error.message}` 
    });
  }
};