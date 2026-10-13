const mongoose = require("mongoose");
const dsaConnection = require("../config/dsaDb");

const userDSAProgressSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
    },
    problemId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    status: {
      type: String,
      enum: ["started", "in_progress", "completed", "abandoned"],
      default: "started",
    },
    hintsUsed: [Number],
    hintsCount: { type: Number, default: 0 },
    intuitionChallengesAttempts: [
      {
        challengeIndex: Number,
        guesses: [{ option: Number, correct: Boolean }],
      },
    ],
    transferQuestionsAttempts: [
      {
        questionIndex: Number,
        guesses: [{ option: Number, correct: Boolean }],
      },
    ],
    correctIntuitionChallenges: { type: Number, default: 0 },
    correctTransferQuestions: { type: Number, default: 0 },
    xpEarned: { type: Number, default: 0 },
    totalAttempts: { type: Number, default: 0 },
    completedAt: Date,
  },
  { timestamps: true }
);

userDSAProgressSchema.index({ userId: 1, problemId: 1 }, { unique: true });

module.exports = dsaConnection.model("UserDSAProgress", userDSAProgressSchema);