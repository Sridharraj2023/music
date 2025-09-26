import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config();

// List of missing files that need to be uploaded
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

function createUploadInstructions() {
  console.log('=== UPLOAD INSTRUCTIONS ===');
  console.log('You need to upload the following files to the uploads directory:');
  console.log('');
  
  console.log('📁 Create a "files-to-upload" directory and place your files there:');
  console.log('mkdir files-to-upload');
  console.log('');
  
  console.log('📋 Missing Audio Files:');
  missingFiles.filter(file => file.match(/\.(mp3|wav)$/)).forEach(file => {
    console.log(`   - ${file}`);
  });
  
  console.log('');
  console.log('🖼️ Missing Image Files:');
  missingFiles.filter(file => file.match(/\.(png|jpeg|jpg)$/)).forEach(file => {
    console.log(`   - ${file}`);
  });
  
  console.log('');
  console.log('📤 Upload Process:');
  console.log('1. Place your audio/image files in the "files-to-upload" directory');
  console.log('2. Run: node copy-files.js');
  console.log('3. Test the files in your Flutter app');
  console.log('');
  
  console.log('🔧 Alternative: Manual Upload');
  console.log('You can also manually copy files to:');
  console.log(`   ${path.join(__dirname, 'uploads')}`);
  console.log('');
  
  console.log('📝 File Requirements:');
  console.log('- Audio files: .mp3 or .wav format');
  console.log('- Image files: .png, .jpeg, or .jpg format');
  console.log('- Keep the exact filenames as shown above');
  console.log('- Files should be properly encoded for web playback');
}

function createCopyScript() {
  const copyScript = `import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const sourceDir = path.join(__dirname, 'files-to-upload');
const targetDir = path.join(__dirname, 'uploads');

// Ensure target directory exists
if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

// List of files to copy
const filesToCopy = [
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

console.log('=== COPYING FILES ===');

let copiedCount = 0;
let missingCount = 0;

filesToCopy.forEach(filename => {
  const sourcePath = path.join(sourceDir, filename);
  const targetPath = path.join(targetDir, filename);
  
  if (fs.existsSync(sourcePath)) {
    try {
      fs.copyFileSync(sourcePath, targetPath);
      console.log(\`✅ Copied: \${filename}\`);
      copiedCount++;
    } catch (error) {
      console.error(\`❌ Error copying \${filename}: \${error.message}\`);
    }
  } else {
    console.log(\`⚠️  Missing: \${filename}\`);
    missingCount++;
  }
});

console.log(\`\\n=== SUMMARY ===\`);
console.log(\`✅ Files copied: \${copiedCount}\`);
console.log(\`⚠️  Files missing: \${missingCount}\`);
console.log(\`📁 Target directory: \${targetDir}\`);

if (missingCount > 0) {
  console.log('\\n📝 Note: Place missing files in the "files-to-upload" directory and run this script again.');
}
`;

  fs.writeFileSync(path.join(__dirname, 'copy-files.js'), copyScript);
  console.log('✅ Created copy-files.js script');
}

// Main execution
console.log('🎵 ELEVATE - File Upload Setup');
console.log('==============================');

createUploadInstructions();
createCopyScript();

console.log('✅ Setup complete!');
console.log('📁 Next steps:');
console.log('1. Create "files-to-upload" directory');
console.log('2. Add your audio/image files to that directory');
console.log('3. Run: node copy-files.js');
console.log('4. Test your Flutter app!');
