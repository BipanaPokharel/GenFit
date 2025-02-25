const socketIo = require('socket.io');
const { Chat, FriendRequest } = require('./models/chat'); 

let users = {};  // Stores active users' socket IDs

function initSocket(server) {
    const io = socketIo(server);

    io.on('connection', (socket) => {
        console.log(`User connected: ${socket.id}`);

        // Handle user joining
        socket.on('join', (userId) => {
            users[userId] = socket.id;
            console.log(`User ${userId} is now online.`);
        });

        // Handle message sending
        socket.on('send_message', async (data) => {
            const { senderId, receiverId, message } = data;

            try {
                // ✅ 1. Check if sender and receiver are friends
                const friendship = await FriendRequest.findOne({
                    where: {
                        sender_id: senderId,
                        receiver_id: receiverId,
                        status: "accepted",
                    },
                });

                if (!friendship) {
                    console.log(`Message blocked: Users ${senderId} & ${receiverId} are not friends.`);
                    socket.emit("error_message", { error: "You can only chat with friends." });
                    return;
                }

                // ✅ 2. Store message in the database
                const chatMessage = await Chat.create({
                    sender_id: senderId,
                    receiver_id: receiverId,
                    message: message,
                });

                // ✅ 3. Send message to receiver if online
                if (users[receiverId]) {
                    io.to(users[receiverId]).emit('receive_message', {
                        senderId,
                        message,
                        timestamp: chatMessage.created_at,
                    });
                }

                // Send confirmation to sender
                socket.emit("message_sent", {
                    receiverId,
                    message,
                    timestamp: chatMessage.created_at,
                });

            } catch (error) {
                console.error("Error processing message:", error);
                socket.emit("error_message", { error: "Message could not be sent." });
            }
        });

        // Handle user disconnecting
        socket.on('disconnect', () => {
            for (let userId in users) {
                if (users[userId] === socket.id) {
                    delete users[userId];
                    console.log(`User ${userId} disconnected.`);
                    break;
                }
            }
        });
    });
}

module.exports = initSocket;
