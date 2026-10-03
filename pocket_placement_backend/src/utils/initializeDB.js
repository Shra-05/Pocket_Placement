const DSAProblem = require("../models/DSAProblem");
const { signalStreamProblem } = require("../data/problems/sliding_window_problems");

const initializeDSAProblems = async () => {
  try {
    // Check if Signal Stream problem exists
    const signalStreamExists = await DSAProblem.findOne({
      title: "Signal Stream",
    });

    if (!signalStreamExists) {
      console.log("[Init] Seeding Signal Stream problem...");
      const problem = new DSAProblem(signalStreamProblem);
      await problem.save();
      console.log("[Init] ✓ Signal Stream problem created");
      return problem._id;
    } else {
      console.log("[Init] ✓ Signal Stream problem already exists");
      return signalStreamExists._id;
    }
  } catch (error) {
    console.error("[Init] Error initializing DSA problems:", error.message);
    throw error;
  }
};

module.exports = { initializeDSAProblems };