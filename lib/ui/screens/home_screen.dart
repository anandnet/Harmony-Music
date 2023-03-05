import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

import '../widgets/content_list_widget.dart';
import '../widgets/quickpickswidget.dart';
import 'home_screen_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlayerController playerController = Get.find<PlayerController>();
  final HomeScreenController homeScreenController =
      Get.find<HomeScreenController>();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: FloatingActionButton(
              focusElevation: 0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              elevation: 0,
              onPressed: () async {
                // file:///data/user/0/com.example.harmonymusic/cache/libCachedImageData/
                //file:///data/user/0/com.example.harmonymusic/cache/just_audio_cache/
                final cacheDir = (await getTemporaryDirectory()).path;
                if (io.Directory("$cacheDir/libCachedImageData/")
                    .existsSync()) {
                  final file =
                      io.Directory("$cacheDir/libCachedImageData/").listSync();
                  inspect(file);
                }
                if (io.Directory("$cacheDir/just_audio_cache/remote/")
                    .existsSync()) {
                  final audioFiles =
                      io.Directory("$cacheDir/just_audio_cache/remote/")
                          .listSync();

                  inspect(audioFiles);
                }
              },
              child: const Icon(Icons.search)),
        ),
      ),
      body: Row(
        children: <Widget>[
          // create a navigation rail
          Obx(
            () => NavigationRail(
              selectedIndex:
                  homeScreenController.tabIndex.value, //_selectedIndex,
              onDestinationSelected: homeScreenController.onTabSelected,
              minWidth: 60,

              leading: const SizedBox(height: 60),
              labelType: NavigationRailLabelType.all,
              //backgroundColor: Colors.green,
              destinations: <NavigationRailDestination>[
                railDestination("Home"),
                railDestination("Songs"),
                railDestination("Playlists"),
                railDestination("Albums"),
                railDestination("Artists"),
                //railDestination("Settings")
              ],
              trailing: Expanded(
                  child: Center(
                      child: IconButton(
                icon: Icon(Icons.equalizer),
                onPressed: () {},
              ))),
            ),
          ),
          //const VerticalDivider(thickness: 1, width: 2),
          Expanded(
            child: Center(
              child: Obx(() {
                if (homeScreenController.tabIndex.value == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 90, top: 90),
                      child: Obx(() {
                        return Column(
                          children: homeScreenController.isContentFetched.value
                              ? (homeScreenController.homeContentList)
                                  .map((element) {
                                  if (element.runtimeType.toString() ==
                                      "QuickPicks") {
                                    return QuickPicksWidget(content: element);
                                  } else {
                                    return ContentListWidget(
                                      content: element,
                                    );
                                  }
                                }).toList()
                              : [const SizedBox()],
                        );
                      }),
                    ),
                  );
                } else {
                  return Center(
                    child: Text("${homeScreenController.tabIndex.value}"),
                  );
                }
              }),
            ),
          )
        ],
      ),
    );
  }

  NavigationRailDestination railDestination(String label) {
    return NavigationRailDestination(
      icon: const SizedBox.shrink(),
      label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: RotatedBox(quarterTurns: -1, child: Text(label))),
    );
  }
}
