// controllers/PostsController.js
const { Post, User, Comment } = require("../models");
const sequelize = require("sequelize");

// ✅ Get all posts
exports.getAllPosts = async (req, res) => {
  try {
    const posts = await Post.findAll({
      include: [
        {
          model: User,
          as: "author",
          attributes: ["user_id", "username", "profile_pic"], // Ensure 'profile_pic' is used here
          required: false,
        },
        {
          model: Comment,
          as: "comments",
          required: false,
          include: [
            {
              model: User,
              attributes: ["user_id", "username", "profile_pic"], // Ensure 'profile_pic' is used here
              required: false,
            },
          ],
        },
      ],
      order: [["created_at", "DESC"]],
    });

    res.status(200).json({
      success: true,
      results: posts,
    });
  } catch (error) {
    console.error("Error fetching posts:", error);
    res.status(500).json({
      success: false,
      error: `Server error: ${error.message}`,
    });
  }
};

// ✅ Create a new post
exports.createPost = async (req, res) => {
  try {
    const { title, content, user_id, image } = req.body;

    if (!title || !content || !user_id) {
      return res.status(400).json({
        success: false,
        error: "Missing required fields",
      });
    }

    const user = await User.findByPk(user_id);
    if (!user) {
      return res.status(404).json({
        success: false,
        error: "User not found",
      });
    }

    const post = await Post.create({
      title,
      content,
      user_id,
      image: image || null,
    });

    res.status(201).json({
      success: true,
      post,
    });
  } catch (error) {
    console.error("Error creating post:", error);
    res.status(500).json({
      success: false,
      error: `Server error: ${error.message}`,
    });
  }
};

// ✅ Get a specific post by ID
exports.getPostById = async (req, res) => {
  try {
    const { id } = req.params;

    const post = await Post.findByPk(id, {
      include: [
        {
          model: User,
          as: "author",
          attributes: ["user_id", "username", "profile_pic"], // Ensure 'profile_pic' is used here
          required: false,
        },
        {
          model: Comment,
          as: "comments",
          required: false,
          include: [
            {
              model: User,
              attributes: ["user_id", "username", "profile_pic"], // Ensure 'profile_pic' is used here
              required: false,
            },
          ],
        },
      ],
    });

    if (!post) {
      return res.status(404).json({
        success: false,
        error: "Post not found",
      });
    }

    res.status(200).json({
      success: true,
      post,
    });
  } catch (error) {
    console.error("Error fetching post:", error);
    res.status(500).json({
      success: false,
      error: `Server error: ${error.message}`,
    });
  }
};

// ✅ Update a post
exports.updatePost = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, content, user_id, image } = req.body;

    const post = await Post.findByPk(id);

    if (!post) {
      return res.status(404).json({
        success: false,
        error: "Post not found",
      });
    }

    if (post.user_id !== parseInt(user_id)) {
      return res.status(403).json({
        success: false,
        error: "You do not have permission to update this post",
      });
    }

    post.title = title || post.title;
    post.content = content || post.content;
    post.image = image || post.image;

    await post.save();

    res.status(200).json({
      success: true,
      message: "Post updated successfully",
      post,
    });
  } catch (error) {
    console.error("Error updating post:", error);
    res.status(500).json({
      success: false,
      error: `Server error: ${error.message}`,
    });
  }
};

// ✅ Delete a post
exports.deletePost = async (req, res) => {
  try {
    const { id } = req.params;
    const { user_id } = req.body;

    const post = await Post.findByPk(id);

    if (!post) {
      return res.status(404).json({
        success: false,
        error: "Post not found",
      });
    }

    if (post.user_id !== parseInt(user_id)) {
      return res.status(403).json({
        success: false,
        error: "You do not have permission to delete this post",
      });
    }

    await post.destroy();

    res.status(200).json({
      success: true,
      message: "Post deleted successfully",
    });
  } catch (error) {
    console.error("Error deleting post:", error);
    res.status(500).json({
      success: false,
      error: `Server error: ${error.message}`,
    });
  }
};
