const mongoose = require("mongoose");
const dsaConnection = require("../config/dsaDb");

const intuitionChallengeSchema = new mongoose.Schema(
  {
    question: String,
    options: [String],
    correct: Number,
    feedback: {
      correct: String,
      incorrect: String,
    },
    visual: mongoose.Schema.Types.Mixed,
  },
  { _id: false }
);

const exampleSchema = new mongoose.Schema(
  {
    input: String,
    output: String,
    explanation: String,
  },
  { _id: false }
);

const approachSchema = new mongoose.Schema(
  {
    description: String,
    timeComplexity: String,
    spaceComplexity: String,
  },
  { _id: false }
);

const transferQuestionSchema = new mongoose.Schema(
  {
    scenario: String,
    question: String,
    options: [String],
    correct: Number,
  },
  { _id: false }
);

const dsaProblemSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      unique: true,
    },
    source: {
      type: String,
      enum: ["LeetCode", "HackerRank", "Codeforces", "Custom"],
      default: "LeetCode",
    },
    sourceUrl: String,
    difficulty: {
      type: String,
      enum: ["Easy", "Medium", "Hard"],
      required: true,
    },
    topics: [String],
    patterns: [String],
    problem: String,
    examples: [exampleSchema],
    intuitionChallenges: [intuitionChallengeSchema],
    hints: [String],
    keyInsight: String,
    bruteForceApproach: approachSchema,
    optimalApproach: approachSchema,
    patternName: String,
    transferQuestions: [transferQuestionSchema],
    xpReward: {
      noHint: { type: Number, default: 100 },
      hint1: { type: Number, default: 80 },
      hint2: { type: Number, default: 60 },
      hint3: { type: Number, default: 40 },
      reveal: { type: Number, default: 20 },
      transferCorrect: { type: Number, default: 50 },
    },
  },
  { timestamps: true }
);

module.exports = dsaConnection.model("DSAProblem", dsaProblemSchema);