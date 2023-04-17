import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/widgets/content_list_widget_item.dart';

import '../navigator.dart';
import '../utils/home_library_controller.dart';
import '../widgets/content_list_widget.dart';
import '../widgets/list_widget.dart';
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
    return Scaffold(
      floatingActionButton: Visibility(
          visible: true,
          child: Obx(
            () => Padding(
              padding: EdgeInsets.only(
                  bottom: playerController.playerPanelMinHeight.value == 0
                      ? 20
                      : 75),
              child: SizedBox(
                height: 60,
                width: 60,
                child: FittedBox(
                  child: FloatingActionButton(
                      focusElevation: 0,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14))),
                      elevation: 0,
                      onPressed: () async {
                        Get.toNamed(ScreenNavigationSetup.searchScreen,
                            id: ScreenNavigationSetup.id);
                        // file:///data/user/0/com.example.harmonymusic/cache/libCachedImageData/
                        //file:///data/user/0/com.example.harmonymusic/cache/just_audio_cache/
                        // final cacheDir = (await getTemporaryDirectory()).path;
                        // if (io.Directory("$cacheDir/libCachedImageData/")
                        //     .existsSync()) {
                        //   final file =
                        //       io.Directory("$cacheDir/cachedSongs").listSync();
                        //   // inspect(file);
                        //   final downloadedFiles =
                        //       io.Directory("$cacheDir/cachedSongs")
                        //           .listSync()
                        //           .where((f) => !['mime', 'part'].contains(
                        //               f.path.replaceAll(RegExp(r'^.*\.'), '')));
                        //   // print(downloadedFiles);
                        // }
                        // if (io.Directory("$cacheDir/libCachedImageData/")
                        //     .existsSync()) {
                        //   final audioFiles =
                        //       io.Directory("$cacheDir/libCachedImageData/")
                        //           .listSync();

                        //   //inspect(audioFiles);
                        // }
                      },
                      child: const Icon(Icons.search)),
                ),
              ),
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
                        GetX<LibrarySongsController>(builder: (controller) {
                          return controller.cachedSongsList.isNotEmpty
                              ? ListWidget(controller.cachedSongsList,
                                  "Library Songs", true)
                              : Center(
                                  child: Text(
                                  "No data!",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ));
                        })
                      ],
                    ),
                  );
                } else if (homeScreenController.tabIndex.value == 2) {
                  return const PlaylistNAlbumLibraryWidget(
                      isAlbumContent: false);
                } else if (homeScreenController.tabIndex.value == 3) {
                  return const PlaylistNAlbumLibraryWidget();
                } else if (homeScreenController.tabIndex.value == 4) {
                  return const LibraryArtistWidget();
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

class LibraryArtistWidget extends StatelessWidget {
  const LibraryArtistWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cntrller = Get.find<LibraryArtistsController>();
    return Padding(
      padding: const EdgeInsets.only(left: 5, top: 90.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Library Artists",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => cntrller.libraryArtists.isNotEmpty
              ? ListWidget(cntrller.libraryArtists, "Library Artists", true)
              : Expanded(
                  child: Center(
                      child: Text(
                  "No data!",
                  style: Theme.of(context).textTheme.titleMedium,
                ))))
        ],
      ),
    );
  }
}

class PlaylistNAlbumLibraryWidget extends StatelessWidget {
  const PlaylistNAlbumLibraryWidget({super.key, this.isAlbumContent = true});
  final bool isAlbumContent;

  @override
  Widget build(BuildContext context) {
    final libralbumCntrller = Get.find<LibraryAlbumsController>();
    final librplstCntrller = Get.find<LibraryPlaylistsController>();
    var size = MediaQuery.of(context).size;

    const double itemHeight = 220;
    const double itemWidth = 180;

    return Padding(
      padding: const EdgeInsets.only(top: 90.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isAlbumContent ? "Library Albums" : "Library Playlists",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(
              () => (isAlbumContent
                      ? libralbumCntrller.libraryAlbums.isNotEmpty
                      : librplstCntrller.libraryPlaylists.isNotEmpty)
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (size.width / itemWidth).ceil(),
                        childAspectRatio: (itemWidth / itemHeight),
                      ),
                      controller: ScrollController(keepScrollOffset: false),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: isAlbumContent
                          ? libralbumCntrller.libraryAlbums.length
                          : librplstCntrller.libraryPlaylists.length,
                      itemBuilder: (context, index) => Center(
                            child: ContentListItem(
                              content: isAlbumContent
                                  ? libralbumCntrller.libraryAlbums[index]
                                  : librplstCntrller.libraryPlaylists[index],
                              isLibraryItem: true,
                            ),
                          ))
                  : Center(
                      child: Text(
                      "No data!",
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
            ),
          )
        ],
      ),
    );
  }
}
