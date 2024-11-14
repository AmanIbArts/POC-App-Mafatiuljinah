import 'dart:developer';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package

class CategoryDetailController extends GetxController {
  // Audio Player Instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Observables for time tracking
  var currentTime = 0.0.obs;
  var totalTime = 0.0.obs;

  // Observables for managing the state
  var isLoading = true.obs;
  var selectedType = 'Arabic'.obs;

  var lyricsList = <Map<String, dynamic>>[].obs;

  get audioPlayer => _audioPlayer;

  @override
  void onInit() {
    super.onInit();
    log("CategoryDetailController initialized");
  }

  @override
  void onClose() {
    super.onClose();
    _audioPlayer.dispose();
    log("Audio player disposed");
  }

  // Method to play or pause the audio
  void playPauseAudio() {
    if (_audioPlayer.state == PlayerState.playing) {
      _audioPlayer.pause();
      log("Audio paused");
    } else {
      _audioPlayer.resume();
      log("Audio resumed");
    }
  }

  // Method to seek to a specific position in the audio
  void seekTo(double position) {
    _audioPlayer.seek(Duration(seconds: position.toInt()));
    log("Audio seeked to position: ${position.toInt()} seconds");
  }

  // Method to initialize and load the audio from URL
  Future<void> initializeAudio(String audioUrl) async {
    try {
      log("Attempting to load audio from URL: $audioUrl");

      await _audioPlayer.setSource(UrlSource(audioUrl));

      log("Audio successfully loaded");

          _audioPlayer.onDurationChanged.listen((duration) {
        log("Audio duration changed: ${duration.inMilliseconds} ms");
        totalTime.value = duration.inSeconds.toDouble();
      });

      _audioPlayer.onPositionChanged.listen((position) {
        log("Current audio position: ${position.inMilliseconds} ms");
        currentTime.value = position.inSeconds.toDouble();
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        log("Audio playback completed");
        currentTime.value = 0.0;
        isLoading.value = false;
      });

      isLoading.value = false;
    } catch (e) {
      // Handle any errors here
      log('Error initializing audio: $e');
      isLoading.value = false;
    }
  }

  void loadCategoryData(List<dynamic> cdata) {
    isLoading(true);

    log("Loading category data...");

    lyricsList.value =
        cdata.map((item) => item as Map<String, dynamic>).toList();

    log("Loaded ${lyricsList.length} lyrics items");

    // Initialize the audio with the first available audio URL
    if (cdata.isNotEmpty && cdata[0]['audiourl'] != null) {
      log("Initializing audio with URL: ${cdata[0]['audiourl']}");
      initializeAudio(cdata[0]['audiourl']);
    } else {
      log("No valid audio URL found in category data");
      isLoading.value = false;
    }
  }

  void changeType(String type) {
    selectedType.value = type;
    log("Changed selected type to: $type");
  }
}
