const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");

// ======================================================
// SIGNUP
// ======================================================

const signup = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "Name, email and password are required",
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Password must be at least 6 characters",
      });
    }

    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: "User with this email already exists",
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      email,
      password: hashedPassword,
    });

    // Create JWT token immediately after signup
    const token = jwt.sign(
      {
        userId: user._id,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d",
      }
    );

    res.status(201).json({
      success: true,
      message: "Account created successfully",
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        skillTestCompleted: user.skillTestCompleted,

        // Streak information
        streak: user.streak,
        longestStreak: user.longestStreak,
      },
    });
  } catch (error) {
    console.error("Signup error:", error.message);

    res.status(500).json({
      success: false,
      message: "Server error during signup",
    });
  }
};

// ======================================================
// LOGIN
// ======================================================

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    const isPasswordCorrect = await bcrypt.compare(
      password,
      user.password
    );

    if (!isPasswordCorrect) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    const token = jwt.sign(
      {
        userId: user._id,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d",
      }
    );

    res.status(200).json({
      success: true,
      message: "Login successful",
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        skillTestCompleted: user.skillTestCompleted,

        // Streak information
        streak: user.streak,
        longestStreak: user.longestStreak,
      },
    });
  } catch (error) {
    console.error("Login error:", error.message);

    res.status(500).json({
      success: false,
      message: "Server error during login",
    });
  }
};

// ======================================================
// COMPLETE SKILL TEST
// ======================================================

const completeSkillTest = async (req, res) => {
  try {
    // Get the logged-in user's ID
    // from the verified JWT token
    const userId = req.user.userId;

    const user = await User.findByIdAndUpdate(
      userId,
      {
        skillTestCompleted: true,
      },
      {
        new: true,
      }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Skill test completed successfully",
      skillTestCompleted: user.skillTestCompleted,
    });
  } catch (error) {
    console.error(
      "Complete skill test error:",
      error.message
    );

    res.status(500).json({
      success: false,
      message: "Server error while completing skill test",
    });
  }
};

// ======================================================
// GET USER STREAK
// ======================================================

const getStreak = async (req, res) => {
  try {
    // Get logged-in user's ID from JWT
    const userId = req.user.userId;

    const user = await User.findById(userId).select(
      "streak longestStreak lastActivityDate"
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.status(200).json({
      success: true,
      streak: user.streak,
      longestStreak: user.longestStreak,
      lastActivityDate: user.lastActivityDate,
    });
  } catch (error) {
    console.error("Get streak error:", error.message);

    res.status(500).json({
      success: false,
      message: "Server error while getting streak",
    });
  }
};

// ======================================================
// UPDATE USER STREAK
// ======================================================

const updateStreak = async (req, res) => {
  try {
    // Get logged-in user's ID from JWT
    const userId = req.user.userId;

    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Get today's date
    const today = new Date();

    // Create date values containing only the date
    // so time does not affect streak calculation.
    const todayDate = new Date(
      today.getFullYear(),
      today.getMonth(),
      today.getDate()
    );

    let currentStreak = user.streak || 0;

    // --------------------------------------------------
    // FIRST ACTIVITY
    // --------------------------------------------------

    if (!user.lastActivityDate) {
      currentStreak = 1;
    } else {
      const lastDate = new Date(user.lastActivityDate);

      const lastActivityOnlyDate = new Date(
        lastDate.getFullYear(),
        lastDate.getMonth(),
        lastDate.getDate()
      );

      // Calculate difference in days
      const differenceInTime =
        todayDate.getTime() -
        lastActivityOnlyDate.getTime();

      const differenceInDays =
        Math.floor(
          differenceInTime / (1000 * 60 * 60 * 24)
        );

      // ------------------------------------------------
      // SAME DAY
      // ------------------------------------------------

      if (differenceInDays === 0) {
        // User has already completed today's activity.
        // Do NOT increase the streak.
        currentStreak = user.streak || 1;
      }

      // ------------------------------------------------
      // NEXT CONSECUTIVE DAY
      // ------------------------------------------------

      else if (differenceInDays === 1) {
        currentStreak = (user.streak || 0) + 1;
      }

      // ------------------------------------------------
      // STREAK BROKEN
      // ------------------------------------------------

      else {
        currentStreak = 1;
      }
    }

    // Update longest streak
    const longestStreak = Math.max(
      user.longestStreak || 0,
      currentStreak
    );

    // Save streak information
    user.streak = currentStreak;
    user.longestStreak = longestStreak;
    user.lastActivityDate = today;

    await user.save();

    res.status(200).json({
      success: true,
      message: "Streak updated successfully",

      streak: user.streak,
      longestStreak: user.longestStreak,
      lastActivityDate: user.lastActivityDate,
    });
  } catch (error) {
    console.error("Update streak error:", error.message);

    res.status(500).json({
      success: false,
      message: "Server error while updating streak",
    });
  }
};

// ======================================================
// EXPORTS
// ======================================================

module.exports = {
  signup,
  login,
  completeSkillTest,
  getStreak,
  updateStreak,
};