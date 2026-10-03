const mongoose = require("mongoose");

const userDSAProgressSchema = new mongoose.Schema(
  {
    // User Reference
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // Problem Reference
    problemId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "DSAProblem",
      required: true,
    },

    // Current Status
    status: {
      type: String,
      enum: ["not_started", "in_progress", "completed", "solved"],
      default: "not_started",
      // not_started: user hasn't viewed it yet
      // in_progress: user is actively working through it
      // completed: user submitted reasoning, solution reviewed
      // solved: user fully understood and correctly reasoned through it
    },

    // Attempt History (Multiple tries allowed)
    attempts: [
      {
        attemptNumber: Number,
        startedAt: Date,
        endedAt: Date,
        timeSpentSeconds: Number,

        // Reasoning Checkpoints (Key Part of Intuition Building)
        reasoningCheckpoints: [
          {
            checkpointNumber: Number,
            // 1: "Understand the problem"
            // 2: "Identify the pattern"
            // 3: "Plan the approach"
            // 4: "Trace through example"
            // 5: "Consider complexity"

            checkpointType: String,
            // e.g., "pattern_identification", "approach_selection", "complexity_check"

            userResponse: String,
            // What the user said/selected at this checkpoint

            isCorrect: Boolean,
            // Did they nail the reasoning at this stage?

            feedbackGiven: String,
            // What feedback was provided to guide them

            completedAt: Date,
          },
        ],

        // Hints Interaction
        hintsUsed: [
          {
            hintLevel: Number,
            hintText: String,
            usedAt: Date,
          },
        ],

        // Final Submission (Their reasoning)
        selectedApproach: {
          type: String,
          // User's chosen algorithmic approach
          // e.g., "sliding_window_two_pointer"
        },

        selectedApproachExplanation: String,
        // Why they chose this approach (in their words)

        // Self-Reflection
        userThoughtProcess: String,
        // "I thought we need to track consecutive elements..."

        // Correctness & Performance
        solutionCorrect: {
          type: Boolean,
          default: null,
          // null = not yet graded, true/false = graded
        },

        // How we determine correctness:
        // 1. Check if reasoning checkpoint answers match expected patterns
        // 2. Check if selected approach is one of the valid approaches
        // 3. Check if they identified correct complexity
        approachScore: Number,
        // 0-100: did they select the right algorithmic approach?

        complexityScore: Number,
        // 0-100: did they correctly assess time/space complexity?

        reasoningScore: Number,
        // 0-100: overall quality of reasoning/explanation

        overallScore: Number,
        // Average of above scores

        // Completion Timestamp
        submittedAt: Date,
      },
    ],

    // Current Attempt (if in_progress)
    currentAttempt: {
      type: Number,
      default: 0,
      // Which attempt number they're on now
    },

    // Best Performance
    bestAttempt: {
      type: Object,
      default: null,
      // Reference to the highest-scoring attempt
      // {
      //   attemptNumber: 1,
      //   overallScore: 85,
      //   approachScore: 90,
      //   complexityScore: 75,
      //   reasoningScore: 85,
      // }
    },

    // Learning Insights
    conceptsMastered: [
      {
        concept: String,
        // "sliding_window_basics", "two_pointer_pattern", "complexity_analysis"
        masteredAt: Date,
        confidence: Number, // 0-100
      },
    ],

    conceptsStruggledWith: [
      {
        concept: String,
        struggles: [String],
        // ["Didn't understand when to shrink window", "Wrong complexity calculation"]
        lastAttemptAt: Date,
      },
    ],

    // Progress Timeline
    startedAt: {
      type: Date,
      default: Date.now,
    },

    lastActivityAt: {
      type: Date,
      default: Date.now,
    },

    completedAt: {
      type: Date,
      default: null,
    },

    // Gamification
    hintsUsedTotal: {
      type: Number,
      default: 0,
    },

    attemptCount: {
      type: Number,
      default: 0,
    },

    totalTimeSpentSeconds: {
      type: Number,
      default: 0,
    },

    // Whether user viewed the solution
    solutionReviewed: {
      type: Boolean,
      default: false,
    },

    solutionReviewedAt: {
      type: Date,
      default: null,
    },

    // Post-Solution Reflection
    understandingLevel: {
      type: String,
      enum: ["not_understood", "partially_understood", "well_understood", "mastered"],
      default: "not_understood",
      // Updated after they review the solution
    },

    // XP & Rewards
    xpEarned: {
      type: Number,
      default: 0,
      // Based on: correctness, attempts needed, hints used, speed
    },

    // Unique Identifier for this progress entry
    uniqueKey: {
      type: String,
      unique: true,
      sparse: true,
      // userId_problemId combination, auto-generated
    },
  },
  {
    timestamps: true,
  }
);

// Middleware: Auto-generate unique key before saving
userDSAProgressSchema.pre("save", function (next) {
  if (this.userId && this.problemId) {
    this.uniqueKey = `${this.userId}_${this.problemId}`;
  }
  next();
});

// Index for fast lookups
userDSAProgressSchema.index({ userId: 1, problemId: 1 });
userDSAProgressSchema.index({ userId: 1, status: 1 });
userDSAProgressSchema.index({ userId: 1, lastActivityAt: -1 });

module.exports = mongoose.model("UserDSAProgress", userDSAProgressSchema);