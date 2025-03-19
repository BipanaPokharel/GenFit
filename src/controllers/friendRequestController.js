const FriendRequest = require('../models/friendrequest');

class FriendRequestController {
  // Send a friend request
  static async sendFriendRequest(req, res) {
    const { senderId, receiverId } = req.body;

    try {
      const newRequest = await FriendRequest.create({
        sender_id: senderId,
        receiver_id: receiverId,
        status: 'pending',
      });
      return res.status(201).json(newRequest);
    } catch (error) {
      console.error('Error sending friend request:', error);
      return res.status(500).json({ error: 'Failed to send friend request', details: error.message });
    }
  }

  // Accept a friend request
  static async acceptFriendRequest(req, res) {
    const { id } = req.params;

    try {
      const [updated] = await FriendRequest.update(
        { status: 'accepted' },
        { where: { id } }
      );

      if (updated) {
        return res.status(200).json({ message: 'Friend request accepted' });
      }
      return res.status(404).json({ error: 'Friend request not found' });
    } catch (error) {
      console.error('Error accepting friend request:', error);
      return res.status(500).json({ error: 'Failed to accept friend request', details: error.message });
    }
  }

  // Reject a friend request (updated to work with PUT)
  static async rejectFriendRequest(req, res) {
    const { id } = req.params;

    try {
      // Choose ONE approach below:

      // Option 1: Delete the request (original behavior)
      const deleted = await FriendRequest.destroy({ where: { id } });

      // Option 2: Update status to 'rejected' (recommended)
      // const [updated] = await FriendRequest.update(
      //   { status: 'rejected' },
      //   { where: { id } }
      // );

      if (deleted) { // or if (updated) for Option 2
        return res.status(200).json({ message: 'Friend request rejected' });
      }
      return res.status(404).json({ error: 'Friend request not found' });
    } catch (error) {
      console.error('Error rejecting friend request:', error);
      return res.status(500).json({ error: 'Failed to reject friend request', details: error.message });
    }
  }

  // Get pending friend requests for a user
  static async getPendingRequests(req, res) {
    const { userId } = req.params;

    try {
      const requests = await FriendRequest.findAll({
        where: {
          receiver_id: userId,
          status: 'pending',
        },
      });
      return res.status(200).json(requests);
    } catch (error) {
      console.error('Error fetching pending requests:', error);
      return res.status(500).json({ error: 'Failed to fetch pending requests', details: error.message });
    }
  }
}

module.exports = FriendRequestController;
