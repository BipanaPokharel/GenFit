const express = require("express");
const fs = require("fs");
const csv = require("csv-parser");

const router = express.Router();
const filePath = "C:/Users/bpnap/Downloads/archive (1)/LatestCSV.CSV";

// Function to parse CSV file
const parseCSV = async () => {
  return new Promise((resolve, reject) => {
    const results = [];

    fs.createReadStream(filePath)
      .pipe(csv()) // Convert CSV into JSON
      .on("data", (data) => results.push(data))
      .on("end", () => resolve(results))
      .on("error", (err) => reject(err));
  });
};

// Route to fetch workout data
router.get("/", async (req, res) => {
  try {
    const workoutData = await parseCSV();
    res.json(workoutData);
  } catch (error) {
    res.status(500).json({ error: "Failed to load workout data" });
  }
});

module.exports = router;
