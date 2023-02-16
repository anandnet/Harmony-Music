import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import '../player/Player.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'home_screen_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlayerController playerController = Get.put(PlayerController());
  final HomeScreenController homeScreenController = Get.put(HomeScreenController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
            child: Icon(Icons.search),
            focusElevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            elevation: 0,
            onPressed: () {}),
      ),
      body: SlidingUpPanel(
        body: Center(
            child: IconButton(
          icon: const Icon(Icons.add),
          onPressed: (){homeScreenController.isContentFetched.isTrue?playerController.pushSongToPlaylist(homeScreenController.quickPicksSongList):null;},
        )),
        minHeight: 70,
        maxHeight: size.height,
        panel: const Player(),
      ),
    );
  }
}
