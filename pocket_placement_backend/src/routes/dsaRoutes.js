const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const dsaController = require("../controllers/dsaController");

const router = express.Router();

// All DSA routes require authentication
router.use(authMiddleware);

// Get a problem (+ user's progress on it)
router.get("/problems/:problemId", dsaController.getProblem);

// Start a new attempt on a problem
router.post("/problems/:problemId/start-attempt", dsaController.startAttempt);

// Submit answer to a reasoning checkpoint
router.post(
  "/problems/:problemId/checkpoint",
  dsaController.submitCheckpoint
);

// Request a hint
router.post("/problems/:problemId/hint", dsaController.getHint);

// Submit final solution for an attempt
router.post(
  "/problems/:problemId/submit-solution",
  dsaController.submitSolution
);

// Get the optimal solution (only after submission)
router.get(
  "/problems/:problemId/solution",
  dsaController.getOptimalSolution
);

module.exports = router;