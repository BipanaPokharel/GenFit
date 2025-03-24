const Reaction = require('../models/reaction');

exports.addReaction = async (req, res) => {
  try {
    const { post_id, user_id, type } = req.body;
    
    if (!post_id || !user_id || !type) {
      return res.status(400).json({ 
        success: false,
        error: 'post_id, user_id, and type are required' 
      });
    }

    const reaction = await Reaction.create({ post_id, user_id, type });
    res.status(201).json({ success: true, data: reaction });
  } catch (error) {
    res.status(400).json({ 
      success: false,
      error: `Error adding reaction: ${error.message}` 
    });
  }
};

exports.removeReaction = async (req, res) => {
  try {
    const reaction = await Reaction.findOne({
      where: {
        post_id: req.params.postId,
        user_id: req.body.user_id
      }
    });

    if (!reaction) {
      return res.status(404).json({ 
        success: false,
        error: 'Reaction not found' 
      });
    }

    await reaction.destroy();
    res.status(204).end();
  } catch (error) {
    res.status(500).json({ 
      success: false,
      error: `Error removing reaction: ${error.message}` 
    });
  }
};