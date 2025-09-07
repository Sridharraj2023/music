const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');

// Get binaural tracks
router.get('/tracks', auth, async (req, res) => {
  try {
    // Mock binaural data - replace with actual database query
    const tracks = [
      {
        id: 1,
        title: "Alpha Waves - Focus",
        frequency: 10,
        duration: 1800,
        category: "focus",
        description: "10Hz alpha waves for enhanced focus and concentration"
      },
      {
        id: 2,
        title: "Theta Waves - Deep Relaxation",
        frequency: 6,
        duration: 2400,
        category: "relaxation",
        description: "6Hz theta waves for deep relaxation and meditation"
      },
      {
        id: 3,
        title: "Delta Waves - Deep Sleep",
        frequency: 2,
        duration: 3600,
        category: "sleep",
        description: "2Hz delta waves for deep sleep and restoration"
      }
    ];

    res.json({
      success: true,
      tracks
    });
  } catch (error) {
    console.error('Error fetching binaural tracks:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch binaural tracks'
    });
  }
});

// Get binaural categories
router.get('/categories', auth, async (req, res) => {
  try {
    const categories = [
      { id: 1, name: "Focus", frequency: "10-12 Hz", description: "Alpha waves for concentration" },
      { id: 2, name: "Relaxation", frequency: "6-8 Hz", description: "Theta waves for deep relaxation" },
      { id: 3, name: "Sleep", frequency: "1-4 Hz", description: "Delta waves for deep sleep" },
      { id: 4, name: "Energy", frequency: "15-20 Hz", description: "Beta waves for energy and alertness" }
    ];

    res.json({
      success: true,
      categories
    });
  } catch (error) {
    console.error('Error fetching binaural categories:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch binaural categories'
    });
  }
});

module.exports = router;
