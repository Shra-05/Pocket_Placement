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

    // Current daily streak
    streak: {
      type: Number,
      default: 0,
    },

    // Highest streak achieved by the user
    longestStreak: {
      type: Number,
      default: 0,
    },

    // Date on which the user last completed a qualifying activity
    lastActivityDate: {
      type: Date,
      default: null,
    },
  },

  {
    timestamps: true,
  }
);

module.exports = mongoose.model("User", userSchema);