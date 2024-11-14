import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/category_detail_controller.dart';
import '../modals/category.dart';
import '../modals/content_data.dart';
import '../widgets/audio_player_widget.dart';
import 'lyrics_tab.dart';

class CategoryDetailView extends StatefulWidget {
  const CategoryDetailView({super.key});

  @override
  _CategoryDetailViewState createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends State<CategoryDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? currentAudioUrl;

  @override
  void initState() {
    super.initState();
    final Category categoryDetails = Get.arguments as Category;
    final cdata = categoryDetails.cdata;

    // Set up TabController based on the number of available types
    final availableTypes = cdata
        .where((e) => e.lyrics.isNotEmpty)
        .map((e) => e.type)
        .toSet()
        .toList();
    _tabController = TabController(length: availableTypes.length, vsync: this);

    final String? initialAudioUrl =
        cdata.isNotEmpty && cdata[0].audiourl.isNotEmpty
            ? cdata[0].audiourl
            : null;

    currentAudioUrl = initialAudioUrl;

    // Listener to update audio URL based on the selected tab
    _tabController.addListener(() {
      final selectedIndex = _tabController.index;
      final String? newAudioUrl = cdata[selectedIndex].audiourl.isNotEmpty
          ? cdata[selectedIndex].audiourl
          : null;

      setState(() {
        currentAudioUrl = newAudioUrl;
      });
    });
    log("---You are in CategoryDetailView---");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CategoryDetailController controller =
        Get.put(CategoryDetailController());
    final Category categoryDetails = Get.arguments as Category;

    final cdata = categoryDetails.cdata;

    // Filter available types and lyrics based on the data provided
    final availableTypes = cdata
        .where((e) => e.lyrics.isNotEmpty)
        .map((e) => e.type)
        .toSet()
        .toList();

    final availableLyrics = {
      for (var item in cdata)
        if (item.lyrics.isNotEmpty) item.type: item.lyrics
    };

    if (availableTypes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(categoryDetails.title),
        ),
        body: const Center(child: Text("No data available")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryDetails.title),
      ),
      body: DefaultTabController(
        length: availableTypes.length,
        child: Column(
          children: [
            // Only show the AudioPlayerWidget if a valid audio URL is available
            if (currentAudioUrl != null && currentAudioUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AudioPlayerWidget(
                  audioUrl: currentAudioUrl!,
                  onPositionChanged: (currentPosition) {
                    controller.currentTime.value =
                        currentPosition.inMilliseconds.toDouble();
                  },
                ),
              ),
            const SizedBox(height: 10),
            TabBar(
              controller: _tabController,
              onTap: (index) {
                controller.changeType(availableTypes[index]);
              },
              tabs: availableTypes.map((type) => Tab(text: type)).toList(),
            ),
            const SizedBox(height: 10),
            Flexible(
              fit: FlexFit.loose,
              child: TabBarView(
                controller: _tabController,
                children: availableTypes.map((type) {
                  final List<Lyrics> lyricsList = availableLyrics[type] ?? [];
                  return LyricsTab(lyricsList: lyricsList);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
