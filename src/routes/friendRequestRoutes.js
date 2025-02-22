// routes/friendRequests.js
const express = require('express');
const router = express.Router();
const FriendRequestController = require('../controllers/friendRequestController'); // Ensure this path is correct

// Send a friend request
router.post('/send', FriendRequestController.sendFriendRequest);

// Accept a friend request
router.put('/accept/:id', FriendRequestController.acceptFriendRequest);

// Reject a friend request
router.delete('/reject/:id', FriendRequestController.rejectFriendRequest);

// Get pending friend requests for a user
router.get('/pending/:userId', FriendRequestController.getPendingRequests);

module.exports = router;
