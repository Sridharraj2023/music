import Music from "../models/Music.js";
import asyncHandler from 'express-async-handler';
import mongoose from 'mongoose';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// @desc    Get all music with category details
// @route   GET /api/music
// @access  Public
const getMusic = asyncHandler(async (req, res) => {
  try {
    console.log('Fetching music from database...');
    const musicList = await Music.find().populate("category", "name description");
    console.log('Music list retrieved:', musicList);
    const musicWithUrls = musicList.map(music => {
      console.log('Raw music item:', music);
      const baseUrl = 'http://localhost:5000/uploads/';
      const fileName = music.fileUrl ? path.basename(music.fileUrl) : null;
      const thumbnailName = music.thumbnailUrl ? path.basename(music.thumbnailUrl) : null;
      return {
        ...music._doc,
        fileUrl: fileName ? `${baseUrl}${fileName}` : null,
        thumbnailUrl: thumbnailName ? `${baseUrl}${thumbnailName}` : null
      };
    });
    console.log('Music with URLs:', musicWithUrls);
    res.json(musicWithUrls);
  } catch (error) {
    console.error('Error in getMusic:', error);
    res.status(500).json({ message: "Server Error", error: error.message });
  }
});
// @desc    Create new music with file and thumbnail upload
// @route   POST /api/music/create
// @access  Private/Admin
const createMusic = asyncHandler(async (req, res) => {
  console.log('Files:', req.files);
  const { title, artist, category, duration, releaseDate } = req.body;
  const audioFile = req.files?.file?.[0];
  const thumbnailFile = req.files?.thumbnail?.[0];

  // Validate required fields
  const missingFields = [];
  if (!title) missingFields.push('title');
  if (!artist) missingFields.push('artist');
  if (!category) missingFields.push('category');
  if (!audioFile) missingFields.push('file');
  if (!duration) missingFields.push('duration');
  if (!releaseDate) missingFields.push('releaseDate');

  if (missingFields.length > 0) {
    return res.status(400).json({
      message: "Missing required fields",
      missing: missingFields
    });
  }

  try {
    const musicData = {
      title,
      artist,
      category: new mongoose.Types.ObjectId(category),
      fileUrl: `/uploads/${audioFile.filename}`,
      duration: Number(duration),
      releaseDate: new Date(releaseDate),
      user: req.user._id
    };

    if (thumbnailFile) {
      musicData.thumbnailUrl = `/uploads/${thumbnailFile.filename}`;
    }

    const music = await Music.create(musicData);
    res.status(201).json(music);
    
  } catch (error) {
    console.error('Create music error:', error);
    res.status(500).json({
      message: "Server Error",
      error: error.message
    });
  }
});

// @desc    Update music
// @route   PUT /api/music/:id
// @access  Private/Admin
const updateMusic = asyncHandler(async (req, res) => {
  try {
    const music = await Music.findById(req.params.id);
    
    if (!music) {
      return res.status(404).json({ message: 'Music not found' });
    }

    // Handle file updates
    const audioFile = req.files?.file?.[0];
    const thumbnailFile = req.files?.thumbnail?.[0];

    // Update fields
    music.title = req.body.title || music.title;
    music.artist = req.body.artist || music.artist;
    music.category = req.body.category || music.category;
    music.duration = req.body.duration || music.duration;
    music.releaseDate = req.body.releaseDate || music.releaseDate;

    if (audioFile) {
      // Remove old audio file
      if (music.fileUrl) {
        const oldFilePath = path.join(__dirname, '../uploads', path.basename(music.fileUrl));
        if (fs.existsSync(oldFilePath)) {
          fs.unlinkSync(oldFilePath);
        }
      }
      music.fileUrl = `/uploads/${audioFile.filename}`;
    }

    if (thumbnailFile) {
      // Remove old thumbnail
      if (music.thumbnailUrl) {
        const oldThumbPath = path.join(__dirname, '../uploads', path.basename(music.thumbnailUrl));
        if (fs.existsSync(oldThumbPath)) {
          fs.unlinkSync(oldThumbPath);
        }
      }
      music.thumbnailUrl = `/uploads/${thumbnailFile.filename}`;
    }

    const updatedMusic = await music.save();
    res.json(updatedMusic);
    
  } catch (error) {
    console.error('Update error:', error);
    res.status(500).json({ 
      message: 'Server Error',
      error: error.message 
    });
  }
});
// @desc    Delete music
// @route   DELETE /api/music/:id
// @access  Private/Admin
const deleteMusic = asyncHandler(async (req, res) => {
  const music = await Music.findById(req.params.id);
  if (!music) {
    res.status(404);
    throw new Error('Music not found');
  }
  await Music.findByIdAndDelete(req.params.id);
  res.json({ message: 'Music deleted successfully' });
});

export { getMusic, createMusic, updateMusic, deleteMusic };