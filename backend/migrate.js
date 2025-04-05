import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Music from './models/Music.js';

dotenv.config();

const migrate = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('MongoDB Connected');

    const musics = await Music.find();
    for (const music of musics) {
      if (music.fileUrl && !music.filePath) {
        music.filePath = music.fileUrl;
        music.fileUrl = undefined;
      }
      if (music.thumbnailUrl && !music.thumbnailPath) {
        music.thumbnailPath = music.thumbnailUrl;
        music.thumbnailUrl = undefined;
      }
      await music.save();
    }
    console.log('Migration completed');
  } catch (error) {
    console.error('Migration error:', error);
  } finally {
    await mongoose.connection.close();
  }
};

migrate();