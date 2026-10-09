const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const {
  getProblems,
  getProblem,
  startAttempt,
  checkpoint,
  getHint,
  submitSolution,
  getSolution,
} = require("../controllers/dsaController");

const router = express.Router();

router.use(authMiddleware);

// List all problems (optional ?topic=Arrays)
router.get("/problems", getProblems);

router.get("/problems/:problemId", getProblem);

router.post("/problems/:problemId/start-attempt", startAttempt);

router.post("/problems/:problemId/checkpoint", checkpoint);

router.post("/problems/:problemId/hint", getHint);

router.post("/problems/:problemId/submit-solution", submitSolution);

router.get("/problems/:problemId/solution", getSolution);

module.exports = router;