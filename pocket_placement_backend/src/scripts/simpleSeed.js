

require("dotenv").config();
const mongoose = require("mongoose");

const seedProblems = async () => {
  try {
    const conn = await mongoose.connect(process.env.DSA_MONGO_URI);
    console.log("Connected ✅");

    const collection = conn.connection.collection("dsaproblems");
    
    const exists = await collection.findOne({ title: "Two Sum" });
    if (exists) {
      console.log("Two Sum already exists");
      await mongoose.connection.close();
      return;
    }

    const result = await collection.insertOne({
      title: "Two Sum v2",
      source: "LeetCode",
      difficulty: "Easy",
      topics: ["Arrays"],
    });

    console.log("Inserted:", result.insertedId);
    await mongoose.connection.close();
  } catch (error) {
    console.error("Error:", error.message);
  }
};

seedProblems();