const DSAProblem = require("../models/DSAProblem");
const UserDSAProgress = require("../models/UserDSAProgress");
const User = require("../models/User");

// Get a specific DSA problem by ID
// Client: User wants to START or CONTINUE a problem
exports.getProblem = async (req, res) => {
  try {
    const { problemId } = req.params;
    const userId = req.user.id; // From auth middleware

    // 1. Fetch the problem
    const problem = await DSAProblem.findById(problemId);

    if (!problem) {
      return res.status(404).json({ message: "Problem not found" });
    }

    // 2. Fetch user's progress on this problem
    let progress = await UserDSAProgress.findOne({
      userId: userId,
      problemId: problemId,
    });

    // 3. If no progress exists, create initial record
    if (!progress) {
      progress = new UserDSAProgress({
        userId: userId,
        problemId: problemId,
        status: "not_started",
        attempts: [],
        currentAttempt: 0,
      });
      await progress.save();
    }

    // 4. Update last activity timestamp
    progress.lastActivityAt = new Date();
    await progress.save();

    // 5. Return problem + user's progress
    res.json({
      success: true,
      problem: {
        id: problem._id,
        title: problem.title,
        description: problem.description,
        algorithmTopic: problem.algorithmTopic,
        difficulty: problem.difficulty,
        problemStatement: problem.problemStatement,
        intuitiveApproach: problem.intuitiveApproach,
        keyInsights: problem.keyInsights,
        patternName: problem.patternName,
        relatedPatterns: problem.relatedPatterns,
        timeComplexity: problem.timeComplexity,
        spaceComplexity: problem.spaceComplexity,
        complexityExplanation: problem.complexityExplanation,
        hints: problem.hints,
        commonMistakes: problem.commonMistakes,
        visualizationData: problem.visualizationData,
        // DO NOT SEND optimalApproach yet - user should reason first
      },
      userProgress: {
        status: progress.status,
        attemptCount: progress.attempts.length,
        currentAttempt: progress.currentAttempt,
        hintsUsedTotal: progress.hintsUsedTotal,
        totalTimeSpentSeconds: progress.totalTimeSpentSeconds,
        bestAttempt: progress.bestAttempt,
        solutionReviewed: progress.solutionReviewed,
        understandingLevel: progress.understandingLevel,
      },
    });
  } catch (error) {
    console.error("Error fetching problem:", error);
    res.status(500).json({ message: "Error fetching problem", error: error.message });
  }
};

// Start a new attempt on a problem
// Client: User clicks "Start Solving" or "Try Again"
exports.startAttempt = async (req, res) => {
  try {
    const { problemId } = req.params;
    const userId = req.user.id;

    // 1. Fetch or create progress record
    let progress = await UserDSAProgress.findOne({
      userId: userId,
      problemId: problemId,
    });

    if (!progress) {
      progress = new UserDSAProgress({
        userId: userId,
        problemId: problemId,
        status: "not_started",
        attempts: [],
        currentAttempt: 0,
      });
    }

    // 2. Create new attempt
    const newAttempt = {
      attemptNumber: progress.attempts.length + 1,
      startedAt: new Date(),
      endedAt: null,
      timeSpentSeconds: 0,
      reasoningCheckpoints: [],
      hintsUsed: [],
      selectedApproach: null,
      selectedApproachExplanation: null,
      userThoughtProcess: null,
      solutionCorrect: null,
      approachScore: null,
      complexityScore: null,
      reasoningScore: null,
      overallScore: null,
      submittedAt: null,
    };

    progress.attempts.push(newAttempt);
    progress.currentAttempt = progress.attempts.length;
    progress.status = "in_progress";
    progress.lastActivityAt = new Date();

    await progress.save();

    res.json({
      success: true,
      message: "Attempt started",
      attemptNumber: newAttempt.attemptNumber,
      progress: {
        status: progress.status,
        currentAttempt: progress.currentAttempt,
        attemptCount: progress.attempts.length,
      },
    });
  } catch (error) {
    console.error("Error starting attempt:", error);
    res.status(500).json({ message: "Error starting attempt", error: error.message });
  }
};

// Submit a reasoning checkpoint answer
// Client: User answers a question at a reasoning checkpoint
exports.submitCheckpoint = async (req, res) => {
  try {
    const { problemId } = req.params;
    const { checkpointNumber, checkpointType, userResponse } = req.body;
    const userId = req.user.id;

    // 1. Fetch progress
    const progress = await UserDSAProgress.findOne({
      userId: userId,
      problemId: problemId,
    });

    if (!progress || progress.currentAttempt === 0) {
      return res.status(400).json({ message: "No active attempt found" });
    }

    const currentAttemptIndex = progress.currentAttempt - 1;
    const attempt = progress.attempts[currentAttemptIndex];

    // 2. Validate checkpoint doesn't already exist
    const existingCheckpoint = attempt.reasoningCheckpoints.find(
      (cp) => cp.checkpointNumber === checkpointNumber
    );

    if (existingCheckpoint) {
      return res.status(400).json({ message: "Checkpoint already submitted" });
    }

    // 3. Evaluate the checkpoint (basic evaluation logic)
    let isCorrect = false;
    let feedbackGiven = "";

    // Different feedback based on checkpoint type
    // This is simplified - in production, you'd have more sophisticated grading
    if (checkpointType === "pattern_identification") {
      // Check if they identified sliding window
      isCorrect =
        userResponse
          .toLowerCase()
          .includes("window") ||
        userResponse.toLowerCase().includes("pointer") ||
        userResponse.toLowerCase().includes("expand") ||
        userResponse.toLowerCase().includes("shrink");

      if (isCorrect) {
        feedbackGiven =
          "✓ Great! You've identified the sliding window pattern. This is the key insight.";
      } else {
        feedbackGiven =
          "Not quite. Think about moving a window across the stream. How can a window expand and shrink?";
      }
    } else if (checkpointType === "approach_selection") {
      // Check if they chose sliding window
      isCorrect =
        userResponse
          .toLowerCase()
          .includes("sliding") ||
        userResponse.toLowerCase().includes("window") ||
        userResponse.toLowerCase().includes("two pointer") ||
        userResponse.toLowerCase().includes("set") ||
        userResponse.toLowerCase().includes("hash");

      if (isCorrect) {
        feedbackGiven =
          "✓ Perfect! Sliding window with a hash set is the optimal approach. This ensures O(n) time.";
      } else {
        feedbackGiven =
          "Not the most efficient. Consider an approach that processes each signal only once.";
      }
    } else if (checkpointType === "complexity_check") {
      // Check if they identified O(n) time, O(k) space
      isCorrect =
        (userResponse.includes("O(n)") ||
          userResponse.includes("O(n)") ||
          userResponse.toLowerCase().includes("linear")) &&
        (userResponse.includes("O(") ||
          userResponse.toLowerCase().includes("space"));

      if (isCorrect) {
        feedbackGiven =
          "✓ Excellent! O(n) time and O(k) space is correct. You understand the efficiency gains.";
      } else {
        feedbackGiven =
          "Close. For sliding window, what's the time complexity? (Hint: each signal is processed once)";
      }
    }

    // 4. Create checkpoint record
    const checkpoint = {
      checkpointNumber: checkpointNumber,
      checkpointType: checkpointType,
      userResponse: userResponse,
      isCorrect: isCorrect,
      feedbackGiven: feedbackGiven,
      completedAt: new Date(),
    };

    attempt.reasoningCheckpoints.push(checkpoint);
    progress.lastActivityAt = new Date();

    await progress.save();

    res.json({
      success: true,
      checkpoint: {
        checkpointNumber: checkpoint.checkpointNumber,
        isCorrect: checkpoint.isCorrect,
        feedbackGiven: checkpoint.feedbackGiven,
      },
      totalCheckpointsAnswered: attempt.reasoningCheckpoints.length,
    });
  } catch (error) {
    console.error("Error submitting checkpoint:", error);
    res
      .status(500)
      .json({
        message: "Error submitting checkpoint",
        error: error.message,
      });
  }
};

// Get a hint for the current attempt
// Client: User clicks "Get Hint"
exports.getHint = async (req, res) => {
  try {
    const { problemId } = req.params;
    const { hintLevel } = req.body;
    const userId = req.user.id;

    // 1. Fetch problem
    const problem = await DSAProblem.findById(problemId);
    if (!problem) {
      return res.status(404).json({ message: "Problem not found" });
    }

    // 2. Find requested hint
    const hint = problem.hints.find((h) => h.level === hintLevel);
    if (!hint) {
      return res.status(404).json({ message: "Hint not found" });
    }

    // 3. Fetch progress and record hint usage
    const progress = await UserDSAProgress.findOne({
      userId: userId,
      problemId: problemId,
    });

    if (!progress || progress.currentAttempt === 0) {
      return res.status(400).json({ message: "No active attempt found" });
    }

    const currentAttemptIndex = progress.currentAttempt - 1;
    const attempt = progress.attempts[currentAttemptIndex];

    // Check if this hint was already used in this attempt
    const alreadyUsed = attempt.hintsUsed.some(
      (h) => h.hintLevel === hintLevel
    );

    if (alreadyUsed) {
      return res
        .status(400)
        .json({ message: "This hint was already used in this attempt" });
    }

    // 4. Record hint usage
    attempt.hintsUsed.push({
      hintLevel: hintLevel,
      hintText: hint.hint,
      usedAt: new Date(),
    });

    progress.hintsUsedTotal += 1;
    progress.lastActivityAt = new Date();

    await progress.save();

    res.json({
      success: true,
      hint: {
        level: hint.level,
        text: hint.hint,
        focusArea: hint.focusArea,
      },
      hintsUsedInAttempt: attempt.hintsUsed.length,
      hintsUsedTotal: progress.hintsUsedTotal,
    });
  } catch (error) {
    console.error("Error getting hint:", error);
    res.status(500).json({ message: "Error getting hint", error: error.message });
  }
};

// Submit final answer for the attempt
// Client: User clicks "Submit Solution" after working through checkpoints
exports.submitSolution = async (req, res) => {
  try {
    const { problemId } = req.params;
    const { selectedApproach, selectedApproachExplanation, userThoughtProcess } =
      req.body;
    const userId = req.user.id;

    // 1. Fetch progress
    const progress = await UserDSAProgress.findOne({
      userId: userId,
      problemId: problemId,
    });

    if (!progress || progress.currentAttempt === 0) {
      return res.status(400).json({ message: "No active attempt found" });
    }

    // 2. Fetch problem for validation
    const problem = await DSAProblem.findById(problemId);
    if (!problem) {
      return res.status(404).json({ message: "Problem not found" });
    }

    const currentAttemptIndex = progress.currentAttempt - 1;
    const attempt = progress.attempts[currentAttemptIndex];

    // 3. Score the attempt
    let approachScore = 0;
    let complexityScore = 0;
    let reasoningScore = 0;

    // Check if approach matches optimal
    if (
      selectedApproach
        .toLowerCase()
        .includes("sliding") ||
      selectedApproach.toLowerCase().includes("window") ||
      selectedApproach.toLowerCase().includes("two pointer")
    ) {
      approachScore = 90; // High score for correct approach
    } else {
      approachScore = 30; // Low score for incorrect approach
    }

    // Check if explanation mentions complexity
    if (
      selectedApproachExplanation.includes("O(n)") ||
      selectedApproachExplanation.includes("linear")
    ) {
      complexityScore = 85;
    } else {
      complexityScore = 40;
    }

    // Quality of reasoning explanation
    reasoningScore = Math.min(
      100,
      50 + Math.floor(selectedApproachExplanation.length / 20)
    );
    // Rough heuristic: longer explanations = more thought

    const overallScore = Math.round(
      (approachScore + complexityScore + reasoningScore) / 3
    );

    // 4. Update attempt
    attempt.selectedApproach = selectedApproach;
    attempt.selectedApproachExplanation = selectedApproachExplanation;
    attempt.userThoughtProcess = userThoughtProcess;
    attempt.approachScore = approachScore;
    attempt.complexityScore = complexityScore;
    attempt.reasoningScore = reasoningScore;
    attempt.overallScore = overallScore;
    attempt.endedAt = new Date();
    attempt.timeSpentSeconds = Math.floor(
      (attempt.endedAt - attempt.startedAt) / 1000
    );
    attempt.submittedAt = new Date();
    attempt.solutionCorrect = overallScore >= 70; // 70+ is "correct"

    // 5. Update progress tracking
    progress.lastActivityAt = new Date();
    progress.status = "completed";
    progress.totalTimeSpentSeconds += attempt.timeSpentSeconds;

    // Update best attempt if this is better
    if (
      !progress.bestAttempt ||
      overallScore > progress.bestAttempt.overallScore
    ) {
      progress.bestAttempt = {
        attemptNumber: attempt.attemptNumber,
        overallScore: overallScore,
        approachScore: approachScore,
        complexityScore: complexityScore,
        reasoningScore: reasoningScore,
      };
    }

    // Calculate XP earned
    let xpEarned = 0;
    if (attempt.solutionCorrect) {
      xpEarned = 100; // Base XP for correct
      if (attempt.hintsUsed.length === 0) xpEarned += 50; // Bonus: no hints
      if (attempt.attemptNumber === 1) xpEarned += 25; // Bonus: first try
    } else {
      xpEarned = 30; // Partial XP for trying
    }

    progress.xpEarned = xpEarned;

    // Update user's DSA XP
    const user = await User.findById(userId);
    if (user) {
      user.dsaTotalXP += xpEarned;
      await user.save();
    }

    await progress.save();

    res.json({
      success: true,
      attempt: {
        attemptNumber: attempt.attemptNumber,
        overallScore: overallScore,
        approachScore: approachScore,
        complexityScore: complexityScore,
        reasoningScore: reasoningScore,
        solutionCorrect: attempt.solutionCorrect,
        xpEarned: xpEarned,
        timeSpentSeconds: attempt.timeSpentSeconds,
      },
      message: attempt.solutionCorrect
        ? "✓ Great reasoning! You understand the approach."
        : "Good attempt. Review the solution to strengthen your understanding.",
    });
  } catch (error) {
    console.error("Error submitting solution:", error);
    res
      .status(500)
      .json({
        message: "Error submitting solution",
        error: error.message,
      });
  }
};

// Get the optimal solution explanation (only after submission)
// Client: User clicks "View Solution" after submitting
exports.getOptimalSolution = async (req, res) => {
  try {
    const { problemId } = req.params;
    const userId = req.user.id;

    // 1. Fetch problem
    const problem = await DSAProblem.findById(problemId);
    if (!problem) {
      return res.status(404).json({ message: "Problem not found" });
    }

    // 2. Verify user has attempted this problem
    const progress = await UserDSAProgress.findOne({
      userId: userId,
      problemId: problemId,
    });

    if (!progress || progress.attempts.length === 0) {
      return res
        .status(400)
        .json({ message: "You must attempt the problem first" });
    }

    // 3. Mark solution as reviewed
    progress.solutionReviewed = true;
    progress.solutionReviewedAt = new Date();
    await progress.save();

    // 4. Return solution explanation
    res.json({
      success: true,
      solution: {
        name: problem.optimalApproach.name,
        steps: problem.optimalApproach.steps,
        pseudocode: problem.optimalApproach.pseudocode,
        complexityExplanation: problem.complexityExplanation,
      },
      followUpQuestions: problem.followUpQuestions,
    });
  } catch (error) {
    console.error("Error fetching solution:", error);
    res
      .status(500)
      .json({
        message: "Error fetching solution",
        error: error.message,
      });
  }
};