const express = require("express");
const { sendMessage, getChatHistory } = require("../controllers/chatController");

const router = express.Router();

// ✅ Send a message
router.post("/send", sendMessage);

// ✅ Get chat history between two users
router.get("/:sender_id/:receiver_id", getChatHistory);

module.exports = router;
