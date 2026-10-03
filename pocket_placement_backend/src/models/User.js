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

    // ============= NEW DSA FIELDS =============
    dsaProblemsAttempted: {
      type: [mongoose.Schema.Types.ObjectId],
      ref: "DSAProblem",
      default: [],
      // Track which DSA problems user has tried
    },

    dsaCurrentProblem: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "DSAProblem",
      default: null,
      // The problem user is currently working on
    },

    dsaTotalXP: {
      type: Number,
      default: 0,
      // XP earned from DSA problems specifically
    },
    // ==========================================
  },

  {
    timestamps: true,
  }
);

module.exports = mongoose.model("User", userSchema);