const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");
const multer = require("multer");
const path = require("path");

// Configure multer storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/profile_pics/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, `user-${req.params.user_id}-${uniqueSuffix}${path.extname(file.originalname)}`);
  }
});

// Configure multer upload
const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

// User routes
router.post("/users", userController.createUser);
router.get("/users", userController.getAllUsers);
router.put("/users/:user_id", userController.updateUser);
router.delete("/users/:user_id", userController.deleteUser);

// Profile picture upload
router.post(
  "/users/:user_id/profile-picture", 
  upload.single('profilePic'), 
  userController.updateProfilePicture
);

// Friend requests
router.get("/users/:user_id/pending-friend-requests", userController.getPendingFriendRequests);
router.put("/friend-requests/:requestId/accept", userController.acceptFriendRequest);
router.put("/friend-requests/:requestId/reject", userController.rejectFriendRequest);

// Meal recommendations
router.post("/recommendations", userController.getMealRecommendations);

// User settings
router.patch("/users/:user_id/settings", userController.updateUserSettings);

module.exports = router;