const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');

// Get music tracks
router.get('/tracks', auth, async (req, res) => {
  try {
    // Mock music data - replace with actual database query
    const tracks = [
      {
        id: 1,
        title: "Relaxing Nature Sounds",
        artist: "Elevate",
        duration: 300,
        category: "nature",
        url: "/audio/nature-sounds.mp3"
      },
      {
        id: 2,
        title: "Ocean Waves",
        artist: "Elevate",
        duration: 600,
        category: "nature",
        url: "/audio/ocean-waves.mp3"
      }
    ];

    res.json({
      success: true,
      tracks
    });
  } catch (error) {
    console.error('Error fetching music tracks:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch music tracks'
    });
  }
});

// Get music categories
router.get('/categories', auth, async (req, res) => {
  try {
    const categories = [
      { id: 1, name: "Nature", description: "Natural sounds and environments" },
      { id: 2, name: "Meditation", description: "Calming meditation tracks" },
      { id: 3, name: "Focus", description: "Concentration and focus music" },
      { id: 4, name: "Sleep", description: "Sleep and relaxation tracks" }
    ];

    res.json({
      success: true,
      categories
    });
  } catch (error) {
    console.error('Error fetching music categories:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch music categories'
    });
  }
});

module.exports = router;
