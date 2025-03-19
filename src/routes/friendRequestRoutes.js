const express = require('express');
const router = express.Router();
const FriendRequestController = require('../controllers/friendRequestController');

// Send a friend request
router.post('/send', FriendRequestController.sendFriendRequest);

// Accept a friend request
router.put('/accept/:id', FriendRequestController.acceptFriendRequest);

// Reject a friend request (changed from delete to put)
router.put('/reject/:id', FriendRequestController.rejectFriendRequest);

// Get pending friend requests for a user
router.get('/pending/:userId', FriendRequestController.getPendingRequests);

module.exports = router;
