const DSAProblem = require("../models/DSAProblem");
const UserDSAProgress = require("../models/UserDSAProgress");
const User = require("../models/User");

// ======================================================
// GET PROBLEM
// ======================================================

const getProblem = async (req, res) => {
  try {
    const { problemId } = req.params;
    const userId = req.user.userId;

    const problem = await DSAProblem.findById(problemId);

    if (!problem) {
      return res.status(404).json({
        success: false,
        message: "Problem not found",
      });
    }

    let progress = await UserDSAProgress.findOne({
      userId,
      problemId,
    });

    const problemResponse = {
      _id: problem._id,
      title: problem.title,
      source: problem.source,
      sourceUrl: problem.sourceUrl,
      difficulty: problem.difficulty,
      topics: problem.topics,
      patterns: problem.patterns,
      problem: problem.problem,
      examples: problem.examples,
      patternName: problem.patternName,
      intuitionChallenges: problem.intuitionChallenges,
      hints: problem.hints,
      keyInsight: problem.keyInsight,
      bruteForceApproach: problem.bruteForceApproach,
      optimalApproach: problem.optimalApproach,
      transferQuestions: problem.transferQuestions,
      xpReward: problem.xpReward,
      userProgress: progress || null,
    };

    res.status(200).json({
      success: true,
      problem: problemResponse,
    });
  } catch (error) {
    console.error("Get problem error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error while fetching problem",
    });
  }
};

// ======================================================
// GET ALL PROBLEMS (list, optional ?topic=Arrays)
// ======================================================

const getProblems = async (req, res) => {
  try {
    const userId = req.user.userId;

    const filter = {};
    // The first entry in a problem's topics array is its main topic
    if (req.query.topic) filter["topics.0"] = req.query.topic;

    const problems = await DSAProblem.find(filter)
      .select("title difficulty topics patterns")
      .sort({ _id: 1 })
      .lean();

    const completedProgress = await UserDSAProgress.find({
      userId,
      status: "completed",
    })
      .select("problemId")
      .lean();

    const completedIds = new Set(
      completedProgress.map((progress) => String(progress.problemId))
    );

    const withStatus = problems.map((problem) => ({
      ...problem,
      completed: completedIds.has(String(problem._id)),
    }));

    res.status(200).json({ success: true, problems: withStatus });
  } catch (error) {
    console.error("Get problems error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error while fetching problems",
    });
  }
};

// ======================================================
// GET TOPICS (one row per topic, built from the problems themselves)
// A new topic appears automatically once a problem with that
// main topic (first entry of "topics") is added to the database.
// ======================================================

const getTopics = async (req, res) => {
  try {
    const userId = req.user.userId;

    const problems = await DSAProblem.find({})
      .select("topics")
      .sort({ _id: 1 })
      .lean();

    const completedProgress = await UserDSAProgress.find({
      userId,
      status: "completed",
    })
      .select("problemId")
      .lean();

    const completedIds = new Set(
      completedProgress.map((progress) => String(progress.problemId))
    );

    const byTopic = new Map();
    for (const problem of problems) {
      const name = problem.topics && problem.topics[0];
      if (!name) continue;

      if (!byTopic.has(name)) {
        byTopic.set(name, { name, total: 0, completed: 0 });
      }

      const entry = byTopic.get(name);
      entry.total += 1;
      if (completedIds.has(String(problem._id))) entry.completed += 1;
    }

    res.status(200).json({
      success: true,
      topics: Array.from(byTopic.values()),
    });
  } catch (error) {
    console.error("Get topics error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error while fetching topics",
    });
  }
};

// ======================================================
// GET ACTIVITY (when the user completed problems, for the streak)
// ======================================================

const getActivity = async (req, res) => {
  try {
    const userId = req.user.userId;

    const completed = await UserDSAProgress.find({
      userId,
      status: "completed",
    })
      .select("completedAt updatedAt")
      .lean();

    const completions = completed
      .map((progress) => progress.completedAt || progress.updatedAt)
      .filter(Boolean)
      .map((date) => new Date(date).toISOString())
      .sort();

    res.status(200).json({ success: true, completions });
  } catch (error) {
    console.error("Get activity error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error while fetching activity",
    });
  }
};

// ======================================================
// START ATTEMPT
// ======================================================

const startAttempt = async (req, res) => {
  try {
    const { problemId } = req.params;
    const userId = req.user.userId;

    const problem = await DSAProblem.findById(problemId);

    if (!problem) {
      return res.status(404).json({
        success: false,
        message: "Problem not found",
      });
    }

    let progress = await UserDSAProgress.findOne({
      userId,
      problemId,
    });

    if (!progress) {
      progress = new UserDSAProgress({
        userId,
        problemId,
        status: "in_progress",
        totalAttempts: 1,
      });
    } else {
      progress.status = "in_progress";
      progress.totalAttempts += 1;
    }

    await progress.save();

    res.status(200).json({
      success: true,
      message: "Attempt started",
      progress: {
        _id: progress._id,
        status: progress.status,
        hintsCount: progress.hintsCount,
        totalAttempts: progress.totalAttempts,
      },
    });
  } catch (error) {
    console.error("Start attempt error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error while starting attempt",
    });
  }
};

// ======================================================
// CHECKPOINT (Save mid-session progress)
// ======================================================

const checkpoint = async (req, res) => {
  try {
    const { problemId } = req.params;
    const {
      intuitionChallengesAttempts,
      transferQuestionsAttempts,
      correctIntuitionChallenges,
      correctTransferQuestions,
    } = req.body;
    const userId = req.user.userId;

    let progress = await UserDSAProgress.findOne({
      userId,
      problemId,
    });

    if (!progress) {
      return res.status(404).json({
        success: false,
        message: "Progress record not found. Start an attempt first.",
      });
    }

    if (intuitionChallengesAttempts) {
      progress.intuitionChallengesAttempts = intuitionChallengesAttempts;
    }

    if (transferQuestionsAttempts) {
      progress.transferQuestionsAttempts = transferQuestionsAttempts;
    }

    if (correctIntuitionChallenges !== undefined) {
      progress.correctIntuitionChallenges = correctIntuitionChallenges;
    }

    if (correctTransferQuestions !== undefined) {
      progress.correctTransferQuestions = correctTransferQuestions;
    }

    await progress.save();

    res.status(200).json({
      success: true,
      message: "Progress saved",
      progress,
    });
  } catch (error) {
    console.error("Checkpoint error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error while saving progress",
    });
  }
};

// ======================================================
// REQUEST HINT
// ======================================================

const getHint = async (req, res) => {
  try {
    const { problemId } = req.params;
    const { hintLevel } = req.body;
    const userId = req.user.userId;

    const problem = await DSAProblem.findById(problemId);

    if (!problem) {
      return res.status(404).json({
        success: false,
        message: "Problem not found",
      });
    }

    if (!problem.hints || hintLevel < 0 || hintLevel >= problem.hints.length) {
      return res.status(400).json({
        success: false,
        message: "Invalid hint level",
      });
    }

    let progress = await UserDSAProgress.findOne({
      userId,
      problemId,
    });

    if (!progress) {
      return res.status(404).json({
        success: false,
        message: "Progress record not found",
      });
    }

    progress.hintsUsed = [...new Set([...progress.hintsUsed, hintLevel])];
    progress.hintsCount = progress.hintsUsed.length;

    await progress.save();

    res.status(200).json({
      success: true,
      hint: problem.hints[hintLevel],
      hintLevel,
      hintsUsed: progress.hintsUsed,
    });
  } catch (error) {
    console.error("Get hint error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error while fetching hint",
    });
  }
};

// ======================================================
// SUBMIT SOLUTION (Mark complete and calculate XP)
// ======================================================

const submitSolution = async (req, res) => {
  try {
    const { problemId } = req.params;
    const userId = req.user.userId;

    const problem = await DSAProblem.findById(problemId);

    if (!problem) {
      return res.status(404).json({
        success: false,
        message: "Problem not found",
      });
    }

    let progress = await UserDSAProgress.findOne({
      userId,
      problemId,
    });

    if (!progress) {
      return res.status(404).json({
        success: false,
        message: "Progress record not found",
      });
    }

    let xpEarned = 0;
    const hintsCount = progress.hintsUsed ? progress.hintsUsed.length : 0;

    if (hintsCount === 0) {
      xpEarned += problem.xpReward.noHint;
    } else if (hintsCount === 1) {
      xpEarned += problem.xpReward.hint1;
    } else if (hintsCount === 2) {
      xpEarned += problem.xpReward.hint2;
    } else if (hintsCount === 3) {
      xpEarned += problem.xpReward.hint3;
    } else {
      xpEarned += problem.xpReward.reveal;
    }

    const correctTransfers = progress.correctTransferQuestions || 0;
    xpEarned += correctTransfers * problem.xpReward.transferCorrect;

    progress.xpEarned = xpEarned;
    progress.status = "completed";
    progress.completedAt = new Date();

    await progress.save();

    const user = await User.findByIdAndUpdate(
      userId,
      {
        $inc: { xp: xpEarned, dsaTotalXP: xpEarned },
        $addToSet: { dsaProblemsAttempted: problemId },
      },
      { new: true }
    );

    res.status(200).json({
      success: true,
      message: "Solution submitted successfully",
      xpEarned,
      totalXP: user.xp,
      dsaTotalXP: user.dsaTotalXP,
    });
  } catch (error) {
    console.error("Submit solution error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error while submitting solution",
    });
  }
};

// ======================================================
// GET SOLUTION (Reveal key insight and approaches)
// ======================================================

const getSolution = async (req, res) => {
  try {
    const { problemId } = req.params;

    const problem = await DSAProblem.findById(problemId);

    if (!problem) {
      return res.status(404).json({
        success: false,
        message: "Problem not found",
      });
    }

    res.status(200).json({
      success: true,
      keyInsight: problem.keyInsight,
      bruteForceApproach: problem.bruteForceApproach,
      optimalApproach: problem.optimalApproach,
      patternName: problem.patternName,
    });
  } catch (error) {
    console.error("Get solution error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error while fetching solution",
    });
  }
};

// ======================================================
// EXPORTS
// ======================================================

module.exports = {
  getProblem,
  getProblems,
  getTopics,
  getActivity,
  startAttempt,
  checkpoint,
  getHint,
  submitSolution,
  getSolution,
};