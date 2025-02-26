const { Chat } = require("../models/chat");


// ✅ Send a message via REST API
const sendMessage = async (req, res) => {
    try {
        const { sender_id, receiver_id, message } = req.body;

        if (!sender_id || !receiver_id || !message) {
            return res.status(400).json({ error: "All fields are required" });
        }

        const chatMessage = await Chat.create({ sender_id, receiver_id, message });

        return res.status(201).json({ message: "Message sent!", chat: chatMessage });
    } catch (error) {
        console.error("Error sending message:", error);
        return res.status(500).json({ error: "Internal Server Error" });
    }
};

// ✅ Get chat history between two users
const getChatHistory = async (req, res) => {
    try {
        const { sender_id, receiver_id } = req.params;

        const chatHistory = await Chat.findAll({
            where: {
                sender_id,
                receiver_id,
            },
            order: [["created_at", "ASC"]], // Show messages in order
        });

        return res.status(200).json(chatHistory);
    } catch (error) {
        console.error("Error fetching chat history:", error);
        return res.status(500).json({ error: "Internal Server Error" });
    }
};

module.exports = { sendMessage, getChatHistory };
