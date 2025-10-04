// import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart';

// class BottomBarController extends GetxController {
//   final AudioPlayer binauralPlayer =
//       AudioPlayer(); // Player for binaural sounds
//   final AudioPlayer musicPlayer = AudioPlayer(); // Player for music tracks

//   var isBinauralPlaying = false.obs;
//   var isMusicPlaying = false.obs;
//   var binauralVolume = 1.0.obs;
//   var musicVolume = 1.0.obs;

//   // Track asset paths
//   var binauralTrack = ''.obs; // Holds the path of the binaural track
//   var musicTrack = ''.obs; // Holds the path of the music track

//   /// Play binaural audio (From Assets)
//   Future<void> playBinaural(String assetPath) async {
//     try {
//       binauralTrack.value = assetPath; // Set the binaural track path
//       await binauralPlayer.setAsset(assetPath); // Load local MP3 file
//       // await binauralPlayer.setUrl(assetPath); // Load local MP3 file
//       binauralPlayer.setVolume(binauralVolume.value);
//       binauralPlayer.play();
//       isBinauralPlaying.value = true;
//     } catch (e) {
//       print("Error playing binaural: $e");
//     }
//   }

//   /// Play music audio (From Assets)
//   Future<void> playMusic(String assetPath) async {
//     try {
//       musicTrack.value = assetPath; // Set the music track path
//       await musicPlayer.setAsset(assetPath); // Load local MP3 file
//       // await musicPlayer.setUrl(assetPath); // Load local MP3 file
//       musicPlayer.setVolume(musicVolume.value);
//       musicPlayer.play();
//       isMusicPlaying.value = true;
//     } catch (e) {
//       print("Error playing music: $e");
//     }
//   }

//   /// **🚀 Stop binaural audio**
//   void stopBinaural() {
//     binauralPlayer.stop();
//     isBinauralPlaying.value = false;
//     hideAudioPlayer();
//   }

//   /// **🚀 Stop music audio**
//   void stopMusic() {
//     musicPlayer.stop();
//     isMusicPlaying.value = false;
//     hideAudioPlayer();
//   }

//   /// **🚀 Hide the audio player when both are stopped**
//   void hideAudioPlayer() {
//     if (!isBinauralPlaying.value && !isMusicPlaying.value) {
//       isBinauralPlaying.value = false;
//       isMusicPlaying.value = false;
//     }
//   }

//   /// Adjust binaural volume
//   void setBinauralVolume(double volume) {
//     binauralVolume.value = volume;
//     binauralPlayer.setVolume(volume);
//   }

//   /// Adjust music volume
//   void setMusicVolume(double volume) {
//     musicVolume.value = volume;
//     musicPlayer.setVolume(volume);
//   }

//   @override
//   void onClose() {
//     binauralPlayer.dispose();
//     musicPlayer.dispose();
//     super.onClose();
//   }
// }

// ////////////////// Above Currect and fix Code ///////////////////////////////////////

import 'package:elevate/Model/music_item.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'Equalizer_Controller.dart';

class BottomBarController extends GetxController {
  final AudioPlayer binauralPlayer =
      AudioPlayer(); // Player for binaural sounds
  final AudioPlayer musicPlayer = AudioPlayer(); // Player for music tracks

  // Playback state
  var isBinauralPlaying = false.obs;
  var isMusicPlaying = false.obs;
  var binauralVolume = 1.0.obs;
  var musicVolume = 1.0.obs;

  // Track if either one has played before
  var hasBinauralPlayed = false.obs;
  var hasMusicPlayed = false.obs;

  // Track asset paths
  var binauralTrack = ''.obs; // Holds the path of the binaural track
  var musicTrack = ''.obs; // Holds the path of the music track

  // Track position and duration
  var binauralPosition = Duration.zero.obs;
  var binauralDuration = Duration.zero.obs;
  var musicPosition = Duration.zero.obs;
  var musicDuration = Duration.zero.obs;

  // Playlist management
  var binauralPlaylist = <String>[].obs;
  var binauralPlaylists = <MusicItem>[].obs;
  var musicPlaylist = <String>[].obs;
  var musicPlaylists = <MusicItem>[].obs;
  var currentBinauralIndex = 0.obs;
  var currentMusicIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize sample playlists (replace with your actual tracks)
    // binauralPlaylist.value = [
    //   'assets/audio/hybrid-epic-hollywood-trailer-247114.mp3',
    //   'assets/audio/hybrid-epic-hollywood-trailer-247114.mp3',
    //   'assets/audio/hybrid-epic-hollywood-trailer-247114.mp3'
    // ];

    // musicPlaylist.value = [
    //   'assets/audio/Lil Mama See Road Runner 128 Kbps.mp3',
    //   'assets/audio/Lil Mama See Road Runner 128 Kbps.mp3',
    //   'assets/audio/Lil Mama See Road Runner 128 Kbps.mp3',
    // ];

    // Set up position and duration listeners
    binauralPlayer.positionStream.listen((position) {
      binauralPosition.value = position;
    });

    binauralPlayer.durationStream.listen((duration) {
      binauralDuration.value = duration ?? Duration.zero;
    });

    musicPlayer.positionStream.listen((position) {
      musicPosition.value = position;
    });

    musicPlayer.durationStream.listen((duration) {
      musicDuration.value = duration ?? Duration.zero;
    });

    // Set up completion listeners to handle auto-next
    binauralPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        nextBinauralTrack();
      }
    });

    musicPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        nextMusicTrack();
      }
    });
  }

  /// Play binaural audio (From Assets)
  Future<void> playBinaural(String assetPath) async {
    try {
      print("🎧 Attempting to play binaural: $assetPath");
      
      if (assetPath.isEmpty) {
        print("❌ Error: Binaural URL is empty");
        return;
      }
      
      binauralTrack.value = assetPath; // Set the binaural track path
      
      // Convert local URLs to production URLs
      final finalUrl = _convertToProductionUrl(assetPath);
      
      print("🎧 Setting URL for binaural player...");
      await binauralPlayer.setUrl(finalUrl); // Load audio file from URL

      print("🎧 Setting volume: ${binauralVolume.value}");
      binauralPlayer.setVolume(binauralVolume.value);
      
      print("🎧 Starting playback...");
      await binauralPlayer.play();
      
      isBinauralPlaying.value = true;
      hasBinauralPlayed.value = true;
      
      print("✅ Binaural playback started successfully");

      // Update current index based on the track
      final index = binauralPlaylist.indexOf(assetPath);
      if (index != -1) {
        currentBinauralIndex.value = index;
        print("🎧 Current binaural index: $index");
      }
      
      // Listen for player state changes with more detailed monitoring
      binauralPlayer.playerStateStream.listen((state) {
        print("🎧 Binaural player state: ${state.processingState}, playing: ${state.playing}");
        
        if (state.processingState == ProcessingState.ready && state.playing) {
          print("🎧 ✅ Binaural is actually playing!");
        } else if (state.processingState == ProcessingState.loading) {
          print("🎧 🔄 Binaural is loading...");
        } else if (state.processingState == ProcessingState.buffering) {
          print("🎧 🔄 Binaural is buffering...");
        } else if (state.processingState == ProcessingState.completed) {
          print("🎧 ✅ Binaural playback completed");
        } else if (state.processingState == ProcessingState.idle) {
          print("🎧 ⏸️ Binaural player is idle");
        }
      });
      
      // Also listen for duration stream to confirm audio is loaded
      binauralPlayer.durationStream.listen((duration) {
        if (duration != null) {
          print("🎧 Audio duration: ${duration.inSeconds} seconds");
        }
      });
      
    } catch (e) {
      print("❌ Error playing binaural: $e");
      print("❌ Error type: ${e.runtimeType}");
      
      // More detailed error analysis
      if (e is PlayerException) {
        print("❌ PlayerException details:");
        print("   - Code: ${e.code}");
        print("   - Message: ${e.message}");
        print("   - URL that failed: $assetPath");
        
        // Common PlayerException codes and their meanings
        switch (e.code) {
          case 0:
            print("❌ Code 0: Source error - URL is invalid or unreachable");
            print("   Possible causes:");
            print("   - URL is malformed");
            print("   - File doesn't exist at URL");
            print("   - Server is down");
            print("   - Network connectivity issues");
            print("   - CORS issues");
            
            // Check if this is a production server 500 error
            final finalUrl = _convertToProductionUrl(assetPath);
            if (finalUrl.contains('elevate-backend-s28.onrender.com')) {
              print("💡 SOLUTION: This file needs to be uploaded to production server");
              print("   File: ${Uri.parse(finalUrl).pathSegments.last}");
              print("   Upload this file from local server to production server");
              print("   Local path: $assetPath");
              print("   Production path: $finalUrl");
            }
            break;
          case 1:
            print("❌ Code 1: Format error - Audio format not supported");
            break;
          case 2:
            print("❌ Code 2: Network error - Network connectivity issues");
            break;
          default:
            print("❌ Unknown PlayerException code: ${e.code}");
        }
      }
      
      // Reset states on error
      isBinauralPlaying.value = false;
      binauralTrack.value = '';
    }
  }

  /// Play music audio (From Assets)
  Future<void> playMusic(String assetPath) async {
    try {
      print("🎵 Attempting to play music: $assetPath");
      
      if (assetPath.isEmpty) {
        print("❌ Error: Music URL is empty");
        return;
      }
      
      // Test URL accessibility
      print("🎵 Testing URL accessibility...");
      try {
        final uri = Uri.parse(assetPath);
        print("🎵 Parsed URI: $uri");
        print("🎵 Scheme: ${uri.scheme}");
        print("🎵 Host: ${uri.host}");
        print("🎵 Path: ${uri.path}");
      } catch (uriError) {
        print("❌ Invalid URL format: $uriError");
      }
      
      musicTrack.value = assetPath; // Set the music track path
      
      // Convert local URLs to production URLs
      final finalUrl = _convertToProductionUrl(assetPath);
      
      print("🎵 Setting URL for music player...");
      await musicPlayer.setUrl(finalUrl); // Load audio file from URL
      
      print("🎵 Setting volume: ${musicVolume.value}");
      musicPlayer.setVolume(musicVolume.value);
      
      print("🎵 Starting playback...");
      await musicPlayer.play();
      
      isMusicPlaying.value = true;
      hasMusicPlayed.value = true;
      
      print("✅ Music playback started successfully");

      // Update current index based on the track
      final index = musicPlaylist.indexOf(assetPath);
      if (index != -1) {
        currentMusicIndex.value = index;
        print("🎵 Current music index: $index");
      }
      
      // Listen for player state changes with more detailed monitoring
      musicPlayer.playerStateStream.listen((state) {
        print("🎵 Music player state: ${state.processingState}, playing: ${state.playing}");
        if (state.processingState == ProcessingState.ready && state.playing) {
          print("🎵 ✅ Music is actually playing!");
        } else if (state.processingState == ProcessingState.loading) {
          print("🎵 🔄 Music is loading...");
        } else if (state.processingState == ProcessingState.buffering) {
          print("🎵 🔄 Music is buffering...");
        } else if (state.processingState == ProcessingState.completed) {
          print("🎵 ✅ Music playback completed");
        } else if (state.processingState == ProcessingState.idle) {
          print("🎵 ⏸️ Music player is idle");
        }
      });
      
      // Also listen for duration stream to confirm audio is loaded
      musicPlayer.durationStream.listen((duration) {
        if (duration != null) {
          print("🎵 Audio duration: ${duration.inSeconds} seconds");
        }
      });
      
    } catch (e) {
      print("❌ Error playing music: $e");
      print("❌ Error type: ${e.runtimeType}");
      
      // More detailed error analysis
      if (e is PlayerException) {
        print("❌ PlayerException details:");
        print("   - Code: ${e.code}");
        print("   - Message: ${e.message}");
        print("   - URL that failed: $assetPath");
        
        // Common PlayerException codes and their meanings
        switch (e.code) {
          case 0:
            print("❌ Code 0: Source error - URL is invalid or unreachable");
            print("   Possible causes:");
            print("   - URL is malformed");
            print("   - File doesn't exist at URL");
            print("   - Server is down");
            print("   - Network connectivity issues");
            print("   - CORS issues");
            
            // Check if this is a production server 500 error
            final finalUrl = _convertToProductionUrl(assetPath);
            if (finalUrl.contains('elevate-backend-s28.onrender.com')) {
              print("💡 SOLUTION: This file needs to be uploaded to production server");
              print("   File: ${Uri.parse(finalUrl).pathSegments.last}");
              print("   Upload this file from local server to production server");
              print("   Local path: $assetPath");
              print("   Production path: $finalUrl");
            }
            break;
          case 1:
            print("❌ Code 1: Format error - Audio format not supported");
            break;
          case 2:
            print("❌ Code 2: Network error - Network connectivity issues");
            break;
          default:
            print("❌ Unknown PlayerException code: ${e.code}");
        }
      }
      
      // Reset states on error
      isMusicPlaying.value = false;
      musicTrack.value = '';
    }
  }

  /// Toggle pause/resume for binaural audio
  void toggleBinauralPlayback() {
    if (isBinauralPlaying.value) {
      binauralPlayer.pause();
      isBinauralPlaying.value = false;
    } else {
      binauralPlayer.play();
      isBinauralPlaying.value = true;
    }
  }

  /// Toggle pause/resume for music audio
  void toggleMusicPlayback() {
    if (isMusicPlaying.value) {
      musicPlayer.pause();
      isMusicPlaying.value = false;
    } else {
      musicPlayer.play();
      isMusicPlaying.value = true;
    }
  }

  /// Play next binaural track
  void nextBinauralTrack() {
    if (binauralPlaylist.isEmpty) return;

    int nextIndex = currentBinauralIndex.value + 1;
    if (nextIndex >= binauralPlaylist.length) {
      nextIndex = 0; // Loop back to the beginning
    }

    currentBinauralIndex.value = nextIndex;
    playBinaural(binauralPlaylist[nextIndex]);
  }

  /// Play previous binaural track
  void previousBinauralTrack() {
    if (binauralPlaylist.isEmpty) return;

    int prevIndex = currentBinauralIndex.value - 1;
    if (prevIndex < 0) {
      prevIndex = binauralPlaylist.length - 1; // Loop to the end
    }

    currentBinauralIndex.value = prevIndex;
    playBinaural(binauralPlaylist[prevIndex]);
  }

  /// Play next music track
  void nextMusicTrack() {
    if (musicPlaylist.isEmpty) return;

    int nextIndex = currentMusicIndex.value + 1;
    if (nextIndex >= musicPlaylist.length) {
      nextIndex = 0; // Loop back to the beginning
    }

    currentMusicIndex.value = nextIndex;
    playMusic(musicPlaylist[nextIndex]);
  }

  /// Play previous music track
  void previousMusicTrack() {
    if (musicPlaylist.isEmpty) return;

    int prevIndex = currentMusicIndex.value - 1;
    if (prevIndex < 0) {
      prevIndex = musicPlaylist.length - 1; // Loop to the end
    }

    currentMusicIndex.value = prevIndex;
    playMusic(musicPlaylist[prevIndex]);
  }

  /// Seek to position in binaural track
  void seekBinaural(Duration position) {
    binauralPlayer.seek(position);
  }

  /// Seek to position in music track
  void seekMusic(Duration position) {
    musicPlayer.seek(position);
  }

  /// **🚀 Stop binaural audio**
  void stopBinaural() {
    binauralPlayer.stop();
    isBinauralPlaying.value = false;
    hideAudioPlayer();
  }

  /// **🚀 Stop music audio**
  void stopMusic() {
    musicPlayer.stop();
    isMusicPlaying.value = false;
    hideAudioPlayer();
  }

  /// **🚀 Hide the audio player when both are stopped**
  void hideAudioPlayer() {
    if (!isBinauralPlaying.value && !isMusicPlaying.value) {
      isBinauralPlaying.value = false;
      isMusicPlaying.value = false;
    }
  }

  /// Adjust binaural volume
  void setBinauralVolume(double volume) {
    binauralVolume.value = volume;
    binauralPlayer.setVolume(volume);
  }

  /// Adjust music volume
  void setMusicVolume(double volume) {
    musicVolume.value = volume;
    musicPlayer.setVolume(volume);
  }

  /// Get track title from path
  // String getTrackTitle(String path) {
  //   if (path.isEmpty) return "Unknown Track";

  //   // Extract filename from path and remove extension
  //   final filename = path.split('/').last.split('.').first;

  //   // Convert to title case (capitalize first letter of each word)
  //   return filename
  //       .split('_')
  //       .map((word) =>
  //           word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
  //       .join(' ');
  // }

  // get music name
  // String getMusicName() {
  //   return currentMusicIndex.value < musicPlaylist.length
  //       ? musicPlaylist[currentMusicIndex.value]
  //       : "Unknown Track";
  // }

  /// Format duration to mm:ss
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void onClose() {
    binauralPlayer.dispose();
    musicPlayer.dispose();
    super.onClose();
  }

  void setAllMusic(List<MusicItem> music) {
    print("🎵 Setting music playlist with ${music.length} items");
    musicPlaylist.value = music.map((item) => item.fileUrl).toList();
    musicPlaylists.value = music;
    
    // Debug: Print first few music URLs and test them
    for (int i = 0; i < music.length && i < 3; i++) {
      print("🎵 Music $i: ${music[i].title} - ${music[i].fileUrl}");
      _testAudioUrl(music[i].fileUrl, "Music ${music[i].title}");
    }
  }

  /// Convert local URLs to production URLs with fallback
  String _convertToProductionUrl(String url) {
    if (url.isEmpty) return url;
    
    try {
      // Handle relative URLs (starting with /uploads/)
      if (url.startsWith('/uploads/')) {
        final productionUrl = 'https://elevate-backend-s28.onrender.com$url';
        print("🔄 Converting relative URL to production URL");
        print("   Original: $url");
        print("   Production: $productionUrl");
        return productionUrl;
      }
      
      final uri = Uri.parse(url);
      
      // Check if it's a local IP address
      if (uri.host.startsWith('192.168.') || uri.host.startsWith('10.') || uri.host == 'localhost' || uri.host == '127.0.0.1') {
        print("🔄 Converting local URL to production URL");
        print("   Original: $url");
        
        // Replace local server with production server and remove port
        final productionUrl = url.replaceAll(uri.host, 'elevate-backend-s28.onrender.com');
        // Remove port number for production server
        final noPortUrl = productionUrl.replaceAll(':5000', '');
        // If it's HTTP, convert to HTTPS for production
        final finalUrl = noPortUrl.replaceAll('http://', 'https://');
        
        print("   Production: $finalUrl");
        return finalUrl;
      }
      
      // If it's already a production URL, return as is
      if (url.contains('elevate-backend-s28.onrender.com')) {
        print("✅ Already using production URL: $url");
        return url;
      }
      
    } catch (e) {
      print("❌ Error converting URL: $e");
    }
    
    return url;
  }

  /// Test if an audio URL is accessible
  Future<void> _testAudioUrl(String url, String name) async {
    if (url.isEmpty) {
      print("❌ $name: URL is empty");
      return;
    }
    
    try {
      final uri = Uri.parse(url);
      print("🔍 Testing $name URL: $url");
      print("   - Scheme: ${uri.scheme}");
      print("   - Host: ${uri.host}");
      print("   - Path: ${uri.path}");
      
      // Check if it's a local IP address
      if (uri.host.startsWith('192.168.') || uri.host.startsWith('10.') || uri.host == 'localhost' || uri.host == '127.0.0.1') {
        print("⚠️  WARNING: $name is using a local IP address (${uri.host})");
        print("   This may not be accessible from your device/emulator");
        print("   Solutions:");
        print("   1. Use the same network as the server");
        print("   2. Use ngrok or similar tunneling service");
        print("   3. Deploy server to a public URL");
        print("   4. Use production API URL instead");
      }
      
      // Test with a simple HTTP HEAD request to check if URL is accessible
      final response = await http.head(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print("⏰ $name: Request timed out after 10 seconds");
          throw Exception('Request timeout');
        },
      );
      print("   - HTTP Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        print("✅ $name: URL is accessible");
      } else {
        print("❌ $name: URL returned status ${response.statusCode}");
      }
    } catch (e) {
      print("❌ $name: URL test failed - $e");
      
      // Provide specific solutions based on error type
      if (e.toString().contains('timeout') || e.toString().contains('Connection refused')) {
        print("💡 Solution: Server is not reachable. Try:");
        print("   1. Check if server is running on ${Uri.parse(url).host}:${Uri.parse(url).port}");
        print("   2. Use production API URL instead of local server");
        print("   3. Use ngrok: ngrok http 5000");
      }
    }
  }

  void setAllBinaural(List<MusicItem> binaural) {
    print("🎧 Setting binaural playlist with ${binaural.length} items");
    binauralPlaylist.value = binaural.map((item) => item.fileUrl).toList();
    binauralPlaylists.value = binaural;
    
    // Debug: Print first few binaural URLs and test them
    for (int i = 0; i < binaural.length && i < 3; i++) {
      print("🎧 Binaural $i: ${binaural[i].title} - ${binaural[i].fileUrl}");
      _testAudioUrl(binaural[i].fileUrl, "Binaural ${binaural[i].title}");
    }
  }

  /// Apply equalizer settings to audio players
  void applyEqualizerSettings() {
    try {
      // Get equalizer controller
      final equalizerController = Get.find<EqualizerController>();
      
      if (!equalizerController.isEqualizerEnabled.value) {
        // If equalizer is disabled, reset to flat
        _resetAudioEffects();
        return;
      }

      // Apply equalizer gains to audio players
      // Note: just_audio doesn't have built-in equalizer support
      // This is a placeholder for future implementation with audio processing libraries
      final gains = equalizerController.equalizerGains.value;
      
      // For now, we'll simulate the effect by adjusting volume slightly
      // In a real implementation, you would use audio processing libraries like:
      // - flutter_audio_processing
      // - audio_waveforms
      // - or native audio processing
      
      print('Applying equalizer settings: ${equalizerController.currentPreset.value}');
      print('Gains: $gains');
      
      // Placeholder: Apply a simple volume adjustment based on overall gain
      final overallGain = gains.reduce((a, b) => a + b) / gains.length;
      final volumeMultiplier = (overallGain + 12) / 24; // Normalize to 0-1
      
      if (isBinauralPlaying.value) {
        binauralPlayer.setVolume(binauralVolume.value * volumeMultiplier);
      }
      if (isMusicPlaying.value) {
        musicPlayer.setVolume(musicVolume.value * volumeMultiplier);
      }
      
    } catch (e) {
      print('Error applying equalizer settings: $e');
    }
  }

  /// Reset audio effects to flat
  void _resetAudioEffects() {
    if (isBinauralPlaying.value) {
      binauralPlayer.setVolume(binauralVolume.value);
    }
    if (isMusicPlaying.value) {
      musicPlayer.setVolume(musicVolume.value);
    }
  }

  /// Get current equalizer preset
  String getCurrentEqualizerPreset() {
    try {
      final equalizerController = Get.find<EqualizerController>();
      return equalizerController.currentPreset.value;
    } catch (e) {
      return 'Flat';
    }
  }

  /// Check if equalizer is enabled
  bool isEqualizerEnabled() {
    try {
      final equalizerController = Get.find<EqualizerController>();
      return equalizerController.isEqualizerEnabled.value;
    } catch (e) {
      return false;
    }
  }
}

