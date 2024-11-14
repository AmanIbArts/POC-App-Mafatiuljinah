import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controllers/category_detail_controller.dart';
import '../modals/content_data.dart';

class LyricsTab extends StatefulWidget {
  final List<Lyrics> lyricsList;

  const LyricsTab({super.key, required this.lyricsList});

  @override
  _LyricsTabState createState() => _LyricsTabState();
}

class _LyricsTabState extends State<LyricsTab> {
  final CategoryDetailController controller =
      Get.find<CategoryDetailController>();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  int _currentHighlightedIndex = 0;

  @override
  void initState() {
    super.initState();

    debugPrint("LyricsTab initialized with ${widget.lyricsList.length} items");

    // Listen to the current audio time from the controller
    ever(controller.currentTime, (currentTimeValue) {
      int newIndex = _findLyricsIndex(currentTimeValue.toInt());

      if (newIndex != -1 && newIndex != _currentHighlightedIndex) {
        setState(() {
          _currentHighlightedIndex = newIndex;
        });

        debugPrint('New highlighted lyrics index: $_currentHighlightedIndex');

        // Scroll to the new highlighted lyrics
        _itemScrollController.scrollTo(
          index: _currentHighlightedIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  int _findLyricsIndex(int currentPosition) {
    for (int i = 0; i < widget.lyricsList.length; i++) {
      final lyrics = widget.lyricsList[i];
      final timeInMilliseconds = _parseTimestamp(lyrics.time);
      final nextTimeInMilliseconds = i < widget.lyricsList.length - 1
          ? _parseTimestamp(widget.lyricsList[i + 1].time)
          : double.infinity.toInt();

      debugPrint(
          'Lyrics index $i: currentTime=$currentPosition ms, startTime=$timeInMilliseconds ms, nextStartTime=$nextTimeInMilliseconds ms');

      if (currentPosition >= timeInMilliseconds &&
          currentPosition < nextTimeInMilliseconds) {
        return i;
      }
    }
    return -1;
  }

  int _parseTimestamp(String time) {
    try {
      final cleanedTime = time.replaceAll('[', '').replaceAll(']', '');
      final parts = cleanedTime.split(':');
      if (parts.length == 2) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        final secondsAndMilliseconds = parts[1].split('.');
        final seconds = int.tryParse(secondsAndMilliseconds[0]) ?? 0;
        final milliseconds = secondsAndMilliseconds.length > 1
            ? (double.parse('0.${secondsAndMilliseconds[1]}') * 1000).toInt()
            : 0;

        final parsedTime =
            (minutes * 60 * 1000) + (seconds * 1000) + milliseconds;

        debugPrint('Parsed timestamp "$time" to $parsedTime ms');

        return parsedTime;
      }
    } catch (e) {
      debugPrint('Error parsing timestamp: $e');
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      itemCount: widget.lyricsList.length,
      itemBuilder: (context, index) {
        final lyrics = widget.lyricsList[index];
        final isHighlighted = index == _currentHighlightedIndex;
        // log("lyrics time from api------->${lyrics.time}");

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: isHighlighted
              ? Colors.yellow.withOpacity(0.3)
              : Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final isArabicHighlighted =
                    controller.selectedType.value.toLowerCase() == "arabic";
                return Visibility(
                  visible: lyrics.arabic.isNotEmpty,
                  child: Text(
                    lyrics.arabic,
                    style: TextStyle(
                      fontSize: isArabicHighlighted ? 22 : 18,
                      fontWeight: isArabicHighlighted
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color:
                          isArabicHighlighted ? Colors.black87 : Colors.black54,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Obx(() {
                final isTransliterationHighlighted =
                    controller.selectedType.value.toLowerCase() ==
                        "transliteration";
                return Visibility(
                  visible: lyrics.translitration.isNotEmpty,
                  child: Text(
                    lyrics.translitration,
                    style: TextStyle(
                      fontSize: isTransliterationHighlighted ? 20 : 16,
                      fontWeight: isTransliterationHighlighted
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isTransliterationHighlighted
                          ? Colors.black87
                          : Colors.black54,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Obx(() {
                final isTranslationHighlighted =
                    controller.selectedType.value.toLowerCase() ==
                        "translation";
                return Visibility(
                  visible: lyrics.translation.isNotEmpty,
                  child: Text(
                    lyrics.translation,
                    style: TextStyle(
                      fontSize: isTranslationHighlighted ? 20 : 16,
                      fontWeight: isTranslationHighlighted
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isTranslationHighlighted
                          ? Colors.black87
                          : Colors.black54,
                    ),
                  ),
                );
              }),
              const Divider(height: 16, thickness: 1),
            ],
          ),
        );
      },
    );
  }
}
