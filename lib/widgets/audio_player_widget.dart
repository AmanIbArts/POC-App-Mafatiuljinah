import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final ValueChanged<Duration>
      onPositionChanged; // Callback for position changes

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
    required this.onPositionChanged, // Required callback
  }) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool isCompleted = false;
  bool hasError = false;
  bool isLoading = true;
  Duration currentTime = Duration.zero;
  Duration totalTime = Duration.zero;
  double volume = 1.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    try {
      setState(() {
        isLoading = true;
      });

      await _audioPlayer.setSource(UrlSource(widget.audioUrl));

      await Future.delayed(const Duration(milliseconds: 500));

      final duration = await _audioPlayer.getDuration();
      if (duration != null && mounted) {
        setState(() {
          totalTime = duration;
        });
      }

      _audioPlayer.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            totalTime = duration;
          });
        }
      });

      _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            currentTime = Duration(
              seconds: min(position.inSeconds, totalTime.inSeconds),
            );
          });

          // Notify the lyrics widget about the current audio position
          widget.onPositionChanged(position);
        }
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            currentTime = Duration.zero;
            isPlaying = false;
            isCompleted = true;
          });
        }
      });

      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
      print("Error loading audio: $e");
    }
  }

  Future<void> _retryLoadingAudio() async {
    if (!mounted) return;

    setState(() {
      hasError = false;
      currentTime = Duration.zero;
      isPlaying = false;
      isCompleted = false;
    });
    await _setupAudio();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (hasError)
            Column(
              children: [
                const Text(
                  "Failed to load audio. Please try again.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _retryLoadingAudio,
                  child: const Text("Retry"),
                ),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      _formatDuration(currentTime),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Expanded(
                      child: Slider(
                        value: currentTime.inSeconds.toDouble(),
                        min: 0,
                        max: totalTime.inSeconds.toDouble(),
                        onChanged: (value) async {
                          await _audioPlayer
                              .seek(Duration(seconds: value.toInt()));
                          if (value == 0) {
                            if (mounted) {
                              setState(() {
                                isPlaying = false;
                              });
                            }
                          }
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white54,
                      ),
                    ),
                    Text(
                      _formatDuration(totalTime),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          volume = volume == 0 ? 1.0 : 0.0;
                          _audioPlayer.setVolume(volume);
                        });
                      },
                      icon: Icon(
                        volume == 0 ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (isPlaying) {
                          await _audioPlayer.pause();
                          if (mounted) {
                            setState(() {
                              isPlaying = false;
                            });
                          }
                        } else {
                          if (isCompleted) {
                            await _audioPlayer.seek(Duration.zero);
                            if (mounted) {
                              setState(() {
                                isCompleted = false;
                              });
                            }
                          }
                          await _audioPlayer.resume();
                          if (mounted) {
                            setState(() {
                              isPlaying = true;
                            });
                          }
                        }
                      },
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
