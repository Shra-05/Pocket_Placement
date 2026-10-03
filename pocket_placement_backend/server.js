const dns = require("dns");
dns.setServers(['8.8.8.8','1.1.1.1'])

const express = require("express");
const cors = require("cors");
require("dotenv").config();

const connectDB = require("./src/config/db");
const authRoutes = require("./src/routes/authRoutes");
const dsaRoutes = require("./src/routes/dsaRoutes");

const app = express();

app.use(cors());
app.use(express.json());

// Mount routes
app.use("/api/auth", authRoutes);
app.use("/api/dsa", dsaRoutes);

app.get("/", (req, res) => {
  res.json({
    message: "Pocket Placement Backend is running 🚀",
  });
});

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
};

startServer();