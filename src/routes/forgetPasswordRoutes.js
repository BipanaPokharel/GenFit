const express = require("express");
const router = express.Router();
const forgetPasswordController = require("../controllers/forgetPasswordController");

router.post("/send-otp", forgetPasswordController.sendOtp);
router.post("/verify-otp", forgetPasswordController.verifyOtpAndResetPassword);

module.exports = router;
