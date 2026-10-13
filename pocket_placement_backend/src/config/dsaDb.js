const mongoose = require("mongoose");

const dsaConnection = mongoose.createConnection(process.env.DSA_MONGO_URI);

dsaConnection.on("connected", () => {
  console.log("DSA MongoDB connected ✅");
});

dsaConnection.on("error", (error) => {
  console.error("DSA MongoDB connection failed ❌", error.message);
});

module.exports = dsaConnection;