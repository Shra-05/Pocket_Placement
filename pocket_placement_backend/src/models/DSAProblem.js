const mongoose = require("mongoose");

const dsaProblemSchema = new mongoose.Schema(
  {
    // Basic Problem Metadata
    title: {
      type: String,
      required: true,
      trim: true,
      // e.g., "Signal Stream"
    },

    description: {
      type: String,
      required: true,
      // Main problem statement
    },

    algorithmTopic: {
      type: String,
      required: true,
      enum: ["sliding_window", "two_pointers", "dynamic_programming", "graph", "greedy"],
      // START: only "sliding_window" for first vertical slice
    },

    difficulty: {
      type: String,
      required: true,
      enum: ["beginner", "intermediate", "advanced"],
      default: "beginner",
    },

    // Core Problem Content (Reasoning-Focused, NOT Code-Focused)
    problemStatement: {
      scenario: {
        type: String,
        required: true,
        // "A user monitors a continuous stream of signals..."
      },
      constraints: [String],
      // ["Signals are integers 1-100", "Stream length up to 1000"]
      examples: [
        {
          input: String,
          output: String,
          explanation: String,
        },
      ],
    },

    // Intuition Builders
    intuitiveApproach: {
      type: String,
      required: true,
      // Explain WHY sliding window works (plain English, no code)
      // "We maintain a window of consecutive signals..."
    },

    keyInsights: [String],
    // ["Expanding window finds candidates", "Shrinking window validates"]

    // Pattern Recognition
    patternName: {
      type: String,
      default: null,
      // "Two-pointer convergence" for this sliding window
    },

    relatedPatterns: [String],
    // ["two pointers", "prefix sum", "hash map"]

    // Complexity Awareness
    timeComplexity: {
      type: String,
      required: true,
      // "O(n)" where n = stream length
    },

    spaceComplexity: {
      type: String,
      required: true,
      // "O(k)" where k = window size
    },

    complexityExplanation: {
      type: String,
      required: true,
      // Explain WHY this is the complexity
    },

    // Interactive Hints (Gated)
    hints: [
      {
        level: Number, // 1, 2, 3 (progressive)
        hint: String,
        focusArea: String, // "window_expansion", "window_shrinkage", "edge_case"
      },
    ],

    // Approach Selection (Key DSA Skill)
    commonMistakes: [
      {
        mistake: String,
        why: String,
        correction: String,
      },
    ],
    // e.g., "Using nested loop instead of sliding window"

    // Solution Reasoning (For Review After Attempt)
    optimalApproach: {
      name: String,
      steps: [String],
      // ["Initialize left/right pointers", "Expand right...", "Shrink left..."]
      pseudocode: String,
      // High-level pseudocode, NOT actual code
    },

    // Visualization Data (For thinking interface)
    visualizationData: {
      type: Object,
      default: null,
      // {
      //   exampleInput: [1, 2, 3, 2, 1],
      //   windowSteps: [
      //     { left: 0, right: 1, values: [1, 2], isValid: false },
      //     { left: 0, right: 2, values: [1, 2, 3], isValid: true },
      //     ...
      //   ]
      // }
    },

    // Interview Adaptability
    followUpQuestions: [
      {
        question: String,
        approach: String,
        // "What if duplicates are allowed?"
      },
    ],

    // Problem Metadata
    createdBy: {
      type: String,
      default: "Pocket Placement",
    },

    isActive: {
      type: Boolean,
      default: true,
    },

    version: {
      type: Number,
      default: 1,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("DSAProblem", dsaProblemSchema);