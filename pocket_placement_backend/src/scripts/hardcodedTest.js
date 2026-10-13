const mongoose = require("mongoose");

const connect = async () => {
  try {
    console.log("Attempting to connect...");
    const conn = await mongoose.connect(
      "mongodb+srv://campus_sphere:YOUR_ACTUAL_PASSWORD@cluster0.ijwsop4.mongodb.net/Pocket_Placement_DSA?retryWrites=true&w=majority",
      { serverSelectionTimeoutMS: 5000 }
    );
    console.log("Connected! ✅");
    await mongoose.connection.close();
  } catch (error) {
    console.error("Failed:", error.message);
  }
};

connect();