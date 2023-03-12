import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

import '../utils/home_library_controller.dart';
import '../widgets/content_list_widget.dart';
import '../widgets/image_widget.dart';
import '../widgets/quickpickswidget.dart';
import '../widgets/shimmer_widgets/home_shimmer.dart';
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
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      floatingActionButton: Visibility(
          visible: true,
          child: Obx(
            () => Padding(
              padding: EdgeInsets.only(
                  bottom: playerController.playerPanelMinHeight.value == 0
                      ? 20
                      : 75),
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
                          io.Directory("$cacheDir/cachedSongs").listSync();
                      // inspect(file);
                      final downloadedFiles =
                          io.Directory("$cacheDir/cachedSongs")
                              .listSync()
                              .where((f) => !['mime', 'part'].contains(
                                  f.path.replaceAll(RegExp(r'^.*\.'), '')));
                      // print(downloadedFiles);
                    }
                    if (io.Directory("$cacheDir/libCachedImageData/")
                        .existsSync()) {
                      final audioFiles =
                          io.Directory("$cacheDir/libCachedImageData/")
                              .listSync();

                      //inspect(audioFiles);
                    }
                  },
                  child: const Icon(Icons.search)),
            ),
          )),
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
              trailing: Center(
                  child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(context)
                        .navigationRailTheme
                        .unselectedLabelTextStyle!
                        .color,
                  ),
                  onPressed: () {},
                ),
              )),
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
                                    //return contentWidget();
                                    return QuickPicksWidget(content: element);
                                  } else {
                                    return ContentListWidget(
                                      content: element,
                                    );
                                  }
                                }).toList()
                              : [const HomeShimmer()],
                        );
                      }),
                    ),
                  );
                } else if (homeScreenController.tabIndex.value == 1) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 5.0, top: 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Library Songs",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(child:
                            GetX<HomeLibrayController>(builder: (controller) {
                          return controller.isSongFetched.value
                              ? ListView.builder(
                                  itemCount: controller.cachedSongsList.length,
                                  padding: const EdgeInsets.only(top: 5),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Material(
                                        child: Obx(() => ListTile(
                                              onTap: () {
                                                playerController.playPlayListSong(
                                                        [...controller
                                                            .cachedSongsList.value], index)
                                                    ;
                                              },
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 0,
                                                      left: 10,
                                                      right: 30),
                                              leading: SizedBox.square(
                                                  dimension: 50,
                                                  child: ImageWidget(
                                                    song: controller
                                                        .cachedSongsList[index],
                                                  )),
                                              title: Text(
                                                controller
                                                    .cachedSongsList[index]
                                                    .title,
                                                maxLines: 1,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              subtitle: Text(
                                                "${controller.cachedSongsList[index].artist[0]["name"]}",
                                                maxLines: 1,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                              trailing: Text(
                                                controller
                                                        .cachedSongsList[index]
                                                        .length ??
                                                    "",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                            )));
                                  },
                                )
                              : const SizedBox.shrink();
                        }))
                      ],
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
