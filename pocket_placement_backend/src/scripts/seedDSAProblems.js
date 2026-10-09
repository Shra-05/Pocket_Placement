
//DNS SERVER ISSUE

//const dns = require('dns');
//dns.setServers(['8.8.8.8', '1.1.1.1']);

const mongoose = require("mongoose");
require("dotenv").config();

const dsaConnection = require("../config/dsaDb");
const DSAProblem = dsaConnection.model("DSAProblem", new mongoose.Schema());

// Wait for DSA connection to be ready
const seedProblems = async () => {
  try {
    // Use the dsaConnection directly
    const DSAProblemModel = require("../models/DSAProblem");

    const existingProblem = await DSAProblemModel.findOne({ title: "Two Sum" });

    if (existingProblem) {
      console.log("Two Sum already exists, skipping seed.");
      await dsaConnection.close();
      return;
    }

    const twoSum = new DSAProblemModel({
      title: "Two Sum",
      source: "LeetCode",
      sourceUrl: "https://leetcode.com/problems/two-sum/",
      difficulty: "Easy",
      topics: ["Arrays", "Hashing"],
      patterns: ["Hashing", "Fast Lookup"],
      problem: `Given an array of integers nums and an integer target, return the indices of the two numbers such that they add up to target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

You can return the answer in any order.`,
      examples: [
        {
          input: "nums = [2,7,11,15], target = 9",
          output: "[0,1]",
          explanation: "Because nums[0] + nums[1] == 9, we return [0, 1].",
        },
      ],
      intuitionChallenges: [
        {
          question: "Given nums = [2,7,11,15] and target = 9, what would you try first?",
          options: [
            "Try every possible pair",
            "Sort the array first",
            "Store previously seen values",
            "Use two pointers",
          ],
          correct: 2,
          feedback: {
            correct: "Exactly!",
            incorrect: "Think about what you really need.",
          },
        },
      ],
      hints: [
        "Think about what information you actually need.",
        "For current number, what value would complete target?",
        "How could you quickly check if that value appeared before?",
        "Store in HashMap and check for complement.",
      ],
      keyInsight:
        "For every number x, only check if target − x already appeared.",
      bruteForceApproach: {
        description: "Check every pair",
        timeComplexity: "O(n²)",
        spaceComplexity: "O(1)",
      },
      optimalApproach: {
        description: "Store previously seen values in HashMap",
        timeComplexity: "O(n)",
        spaceComplexity: "O(n)",
      },
      patternName: "Hashing / Fast Lookup",
      transferQuestions: [
        {
          scenario: "nums = [3,2,4], target = 6",
          question: "You're at 4. What value completes the pair?",
          options: ["1", "2", "3", "4"],
          correct: 1,
        },
      ],
      xpReward: {
        noHint: 100,
        hint1: 80,
        hint2: 60,
        hint3: 40,
        reveal: 20,
        transferCorrect: 50,
      },
    });

    await twoSum.save();

    console.log("✅ Two Sum problem seeded successfully!");
    console.log(`Problem ID: ${twoSum._id}`);
  } catch (error) {
    console.error("Seed error:", error.message);
  } finally {
    await dsaConnection.close();
    console.log("DSA Database connection closed.");
  }
};

// Wait for connection to be ready
dsaConnection.once("open", seedProblems);