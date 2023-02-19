import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/quick_picks.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import '../../models/song.dart';
import '../player/Player.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../widgets/playlist_list_widget.dart';
import '../widgets/quickpickswidget.dart';
import 'home_screen_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlayerController playerController = Get.put(PlayerController());
  final HomeScreenController homeScreenController =
      Get.put(HomeScreenController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: FloatingActionButton(
              focusElevation: 0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              elevation: 0,
              onPressed: () {},
              child: const Icon(Icons.search)),
        ),
      ),
      body: SlidingUpPanel(
        body: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100,top: 100),
            child: Obx(() {
              return Column(
                children: homeScreenController.isContentFetched.value
                    ? (homeScreenController.homeContentList).map((element) {
                        if (element.runtimeType.toString() == "QuickPicks") {
                          return QuickPicksWidget(content: element);
                        } else {
                          return PlaylistListWidget(
                            content: element,
                          );
                        }
                      }).toList()
                    : [const SizedBox()],
              );
            }),
          ),
        ),
        //  Center(
        //     child: IconButton(
        //   icon: const Icon(Icons.add),
        //   onPressed: (){homeScreenController.isContentFetched.isTrue?playerController.pushSongToPlaylist(homeScreenController.quickPicksSongList):null;},
        // )),
        minHeight: 70,
        maxHeight: size.height,
        panel: const Player(),
      ),
    );
  }
}