const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController.js");
const multer = require("multer");
const upload = multer({ dest: "uploads/" });

router.post("/users", userController.createUser);
router.get("/users", userController.getAllUsers);
router.put("/users/:user_id", userController.updateUser);
router.delete("/users/:user_id", userController.deleteUser);
router.post("/users/:user_id/profile-picture", upload.single("profilePic"), userController.updateProfilePicture);

router.get("/users/:user_id/pending-friend-requests", userController.getPendingFriendRequests);
router.put("/friend-requests/:requestId/accept", userController.acceptFriendRequest);
router.put("/friend-requests/:requestId/reject", userController.rejectFriendRequest);

router.post("/recommendations", userController.getMealRecommendations);

module.exports = router;
