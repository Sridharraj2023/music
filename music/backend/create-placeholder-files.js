import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// List of missing files from the Flutter logs
const missingFiles = [
  // Audio files
  '1745691817937-363653959_Sub-Urban---Cradles.mp3',
  '1745691970217-561282124_deepmedi.wav',
  '1745716638125-337724393_12Hz-Binaural-Beats-Healing-Meditation-with-396Hz-528Hz-639Hz-Solfeggio-Frequencies.wav',
  '1745826004997-735441610_noncopyright.mp3',
  '1745826100385-465587109_pianos.mp3',
  '1745923526700-973882842_file_example_WAV_5MG.wav',
  '1746069139986-653012116_528-Hz-783-Hz-Pure-Tone.wav',
  '1746076813739-312622222_963and2hzSuperHumanSleepSnippet.wav',
  '1746199473887-650329480_174-Hz-grounding.wav',
  
  // Image files
  '1745691977346-329608825_images.png',
  '1745691970491-553116607_Deep-Medi.png',
  '1745716639415-502869343_12Hz.png',
  '1745826005004-488107429_pic2.jpeg',
  '1745826100387-833682321_pic3.jpeg',
  '1745923526940-454025515_figma.png',
  '1746069142117-504583231_12Hz-1.png',
  '1746076819286-707681466_Superhuman-Sleep.png',
  '1746199474999-162975513_174-Hz-Grounding.png'
];

console.log('🎵 Creating placeholder files...');

let createdCount = 0;

missingFiles.forEach(filename => {
  const filePath = path.join(uploadsDir, filename);
  
  try {
    if (filename.match(/\.(mp3|wav)$/)) {
      // Create a minimal audio file (1 second of silence)
      const audioBuffer = Buffer.from([
        0x52, 0x49, 0x46, 0x46, // "RIFF"
        0x26, 0x00, 0x00, 0x00, // File size
        0x57, 0x41, 0x56, 0x45, // "WAVE"
        0x66, 0x6D, 0x74, 0x20, // "fmt "
        0x10, 0x00, 0x00, 0x00, // Format chunk size
        0x01, 0x00,             // Audio format (PCM)
        0x01, 0x00,             // Number of channels
        0x44, 0xAC, 0x00, 0x00, // Sample rate
        0x88, 0x58, 0x01, 0x00, // Byte rate
        0x02, 0x00,             // Block align
        0x10, 0x00,             // Bits per sample
        0x64, 0x61, 0x74, 0x61, // "data"
        0x02, 0x00, 0x00, 0x00, // Data size
        0x00, 0x00, 0x00, 0x00  // Silent audio data
      ]);
      fs.writeFileSync(filePath, audioBuffer);
    } else if (filename.match(/\.(png|jpeg|jpg)$/)) {
      // Create a minimal image file (1x1 pixel PNG)
      const imageBuffer = Buffer.from([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
        0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
        0x49, 0x48, 0x44, 0x52, // "IHDR"
        0x00, 0x00, 0x00, 0x01, // Width: 1
        0x00, 0x00, 0x00, 0x01, // Height: 1
        0x08, 0x02, 0x00, 0x00, 0x00, // Bit depth, color type, compression, filter, interlace
        0x90, 0x77, 0x53, 0xDE, // CRC
        0x00, 0x00, 0x00, 0x0C, // IDAT chunk length
        0x49, 0x44, 0x41, 0x54, // "IDAT"
        0x08, 0x99, 0x01, 0x01, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, // Compressed data
        0x00, 0x00, 0x00, // CRC
        0x00, 0x00, 0x00, 0x00, // IEND chunk length
        0x49, 0x45, 0x4E, 0x44, // "IEND"
        0xAE, 0x42, 0x60, 0x82  // CRC
      ]);
      fs.writeFileSync(filePath, imageBuffer);
    }
    
    console.log(`✅ Created: ${filename}`);
    createdCount++;
  } catch (error) {
    console.error(`❌ Error creating ${filename}: ${error.message}`);
  }
});

console.log(`\n🎉 Created ${createdCount} placeholder files!`);
console.log(`📁 Location: ${uploadsDir}`);
console.log('\n📝 Note: These are placeholder files. Replace them with your actual audio/image files for full functionality.');
console.log('\n🧪 Test your Flutter app now - images should load and audio should play (though with placeholder content).');
