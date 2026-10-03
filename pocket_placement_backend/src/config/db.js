const mongoose = require("mongoose");
const { initializeDSAProblems } = require("../utils/initializeDB");

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || "mongodb://localhost:27017/pocket_placement");
    console.log("✓ MongoDB connected");

    // Auto-initialize DSA problems
    await initializeDSAProblems();

    return mongoose.connection;
  } catch (error) {
    console.error("✗ MongoDB connection error:", error.message);
    process.exit(1);
  }
};

module.exports = connectDB;