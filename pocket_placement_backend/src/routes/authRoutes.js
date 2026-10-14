const express = require("express");

const {
  signup,
  login,
  completeSkillTest,
  getStreak,
  updateStreak,
} = require("../controllers/authController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// ======================================================
// SIGNUP
// ======================================================

router.post("/signup", signup);

// ======================================================
// LOGIN
// ======================================================

router.post("/login", login);

// ======================================================
// MARK SKILL QUEST AS COMPLETED
// ======================================================

router.put(
  "/skill-test-complete",
  authMiddleware,
  completeSkillTest
);

// ======================================================
// GET USER STREAK
// ======================================================

router.get(
  "/streak",
  authMiddleware,
  getStreak
);

// ======================================================
// UPDATE USER STREAK
// ======================================================

router.post(
  "/streak/update",
  authMiddleware,
  updateStreak
);

module.exports = router;