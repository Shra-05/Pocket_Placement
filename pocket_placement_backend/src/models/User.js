const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    password: {
      type: String,
      required: true,
    },

    selectedTheme: {
      type: String,
      default: null,
    },

    skillTestCompleted: {
      type: Boolean,
      default: false,
    },

    currentLevel: {
      type: Number,
      default: 1,
    },

    xp: {
      type: Number,
      default: 0,
    },

    streak: {
      type: Number,
      default: 0,
    },

    dsaProblemsAttempted: {
      type: [mongoose.Schema.Types.ObjectId],
      ref: "DSAProblem",
      default: [],
    },

    dsaCurrentProblem: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "DSAProblem",
      default: null,
    },

    dsaTotalXP: {
      type: Number,
      default: 0,
    },
  },

  {
    timestamps: true,
  }
);

module.exports = mongoose.model("User", userSchema);