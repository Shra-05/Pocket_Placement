const mongoose = require("mongoose");
require("dotenv").config();

const DSAProblem = require("../models/DSAProblem");
const { signalStreamProblem } = require("../data/problems/sliding_window_problems");

const seedDSAProblems = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || "mongodb://localhost:27017/pocket_placement");
    console.log("✓ Connected to MongoDB");

    // Check if Signal Stream problem already exists
    const existingProblem = await DSAProblem.findOne({
      title: "Signal Stream",
    });

    if (existingProblem) {
      console.log("⚠ Signal Stream problem already exists in database");
      console.log(`  Problem ID: ${existingProblem._id}`);
      console.log("  Skipping seed (delete if you want to re-seed)");
      await mongoose.disconnect();
      return;
    }

    // Create and save Signal Stream problem
    const problem = new DSAProblem(signalStreamProblem);
    await problem.save();

    console.log("✓ Successfully seeded Signal Stream problem");
    console.log(`  Problem ID: ${problem._id}`);
    console.log(`  Title: ${problem.title}`);
    console.log(`  Topic: ${problem.algorithmTopic}`);
    console.log(`  Difficulty: ${problem.difficulty}`);

    // Disconnect
    await mongoose.disconnect();
    console.log("✓ Disconnected from MongoDB");

    process.exit(0);
  } catch (error) {
    console.error("✗ Error seeding problems:", error.message);
    process.exit(1);
  }
};

// Run the seed
seedDSAProblems();