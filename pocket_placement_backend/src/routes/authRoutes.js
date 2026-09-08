const express = require("express");

const {
  signup,
  login,
  completeSkillTest,
} = require("../controllers/authController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();


// Signup
router.post("/signup", signup);


// Login
router.post("/login", login);


// Mark Skill Quest as completed
router.put(
  "/skill-test-complete",
  authMiddleware,
  completeSkillTest
);


module.exports = router;