const Post = require('../models/post');


exports.createPost = async (req, res) => {
    try {
        const { title, user_id, content, image } = req.body;
        if (!title || !content || !user_id) {
            return res.status(400).json({ error: 'Title, content, and user_id are required' });
        }

        const post = await Post.create({ title, user_id, content, image });
        res.status(201).json(post);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

exports.getPostById = async (req, res) => {
    try {
        const post = await Post.findByPk(req.params.id, {
            include: [
                { model: Comment },
                { model: Reaction }
            ]
        });
        if (!post) return res.status(404).json({ error: 'Post not found' });
        res.json(post);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.updatePost = async (req, res) => {
    try {
        const post = await Post.findByPk(req.params.id);
        if (!post) return res.status(404).json({ error: 'Post not found' });
        
        if (post.user_id !== req.body.user_id) {
            return res.status(403).json({ error: 'Unauthorized' });
        }

        const updatedPost = await post.update(req.body);
        res.json(updatedPost);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

exports.deletePost = async (req, res) => {
    try {
        const post = await Post.findByPk(req.params.id);
        if (!post) return res.status(404).json({ error: 'Post not found' });

        if (post.user_id !== req.body.user_id) {
            return res.status(403).json({ error: 'Unauthorized' });
        }

        await post.destroy();
        res.status(204).end();
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
