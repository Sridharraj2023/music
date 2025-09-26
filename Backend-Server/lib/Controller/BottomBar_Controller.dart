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
      binauralTrack.value = assetPath; // Set the binaural track path
      // await binauralPlayer.setAsset(assetPath); // Load local MP3 file
      await binauralPlayer.setUrl(assetPath); // Load local MP3 file

      binauralPlayer.setVolume(binauralVolume.value);
      binauralPlayer.play();
      isBinauralPlaying.value = true;
      hasBinauralPlayed.value = true;

      // Update current index based on the track
      final index = binauralPlaylist.indexOf(assetPath);
      if (index != -1) {
        currentBinauralIndex.value = index;
      }
    } catch (e) {
      print("Error playing binaural: $e");
    }
  }

  /// Play music audio (From Assets)
  Future<void> playMusic(String assetPath) async {
    try {
      musicTrack.value = assetPath; // Set the music track path
      await musicPlayer.setUrl(assetPath); // Load local MP3 file
      musicPlayer.setVolume(musicVolume.value);
      musicPlayer.play();
      isMusicPlaying.value = true;
      hasMusicPlayed.value = true;

      // Update current index based on the track
      final index = musicPlaylist.indexOf(assetPath);
      if (index != -1) {
        currentMusicIndex.value = index;
      }
    } catch (e) {
      print("Error playing music: $e");
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
    musicPlaylist.value = music.map((item) => item.fileUrl).toList();
    musicPlaylists.value = music;
  }

  void setAllBinaural(List<MusicItem> binaural) {
    binauralPlaylist.value = binaural.map((item) => item.fileUrl).toList();
    binauralPlaylists.value = binaural;
  }
}
