import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/helper.dart';
import '/ui/screens/settings_screen_controller.dart';
import '/ui/player/player_controller.dart';
import '/ui/widgets/content_list_widget_item.dart';
import '/ui/widgets/create_playlist_dialog.dart';
import '../../models/playlist.dart';
import '../navigator.dart';
import '../utils/home_library_controller.dart';
import '../widgets/content_list_widget.dart';
import '../widgets/list_widget.dart';
import '../widgets/quickpickswidget.dart';
import '../widgets/shimmer_widgets/home_shimmer.dart';
import '../widgets/sort_widget.dart';
import 'home_screen_controller.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final HomeScreenController homeScreenController =
        Get.find<HomeScreenController>();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: Obx(
        () => homeScreenController.tabIndex.value == 0 ||
                homeScreenController.tabIndex.value == 2
            ? Obx(
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14))),
                          elevation: 0,
                          onPressed: () async {
                            if (homeScreenController.tabIndex.value == 2) {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const CreateNRenamePlaylistPopup());
                            } else {
                              Get.toNamed(ScreenNavigationSetup.searchScreen,
                                  id: ScreenNavigationSetup.id);
                            }
                            // file:///data/user/0/com.example.harmonymusic/cache/libCachedImageData/
                            //file:///data/user/0/com.example.harmonymusic/cache/just_audio_cache/
                          },
                          child: Icon(homeScreenController.tabIndex.value == 2
                              ? Icons.add
                              : Icons.search_rounded)),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
      body: Row(
        children: <Widget>[
          // create a navigation rail
          Obx(
            () => NavigationRail(
              useIndicator: false,
              selectedIndex:
                  homeScreenController.tabIndex.value, //_selectedIndex,
              onDestinationSelected: homeScreenController.onTabSelected,
              minWidth: 60,
              leading: SizedBox(height: size.height < 750 ? 30 : 60),
              labelType: NavigationRailLabelType.all,
              //backgroundColor: Colors.green,
              destinations: <NavigationRailDestination>[
                railDestination("Home"),
                railDestination("Songs"),
                railDestination("Playlists"),
                railDestination("Albums"),
                railDestination("Artists"),
                //railDestination("Settings")
                const NavigationRailDestination(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  icon: Icon(Icons.settings_rounded),
                  label: SizedBox.shrink(),
                  selectedIcon: Icon(Icons.settings_rounded),
                )
              ],
            ),
          ),
          //const VerticalDivider(thickness: 1, width: 2),
          Expanded(
            child: Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                // switchInCurve: Curves.easeIn,
                // switchOutCurve: Curves.easeOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(1.2, 0),
                              end: const Offset(0, 0))
                          .animate(animation),
                      child: child);
                },
                layoutBuilder: (currentChild, previousChildren) =>
                    currentChild!,
                child: Center(
                  key: ValueKey<int>(homeScreenController.tabIndex.value),
                  child: const Body(),
                ),
              ),
            ),
          ),
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

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    final size = MediaQuery.of(context).size;
    final topPadding = size.height < 750 ? 80.0 : 85.0;
    if (homeScreenController.tabIndex.value == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: Obx(
          () => homeScreenController.networkError.isTrue
              ? SizedBox(
                  height: MediaQuery.of(context).size.height - 180,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Home",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Oops Network Error!",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .color,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: InkWell(
                                    onTap: () {
                                      homeScreenController.init();
                                    },
                                    child: Text(
                                      "Retry!",
                                      style: TextStyle(
                                          color: Theme.of(context).canvasColor),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      )
                    ],
                  ),
                )
              : Obx(() {
                  final items = homeScreenController.isContentFetched.value
                      ? [
                          Obx(() => QuickPicksWidget(
                              content: homeScreenController.quickPicks.value)),
                          ...getWidgetList(homeScreenController.middleContent),
                          ...getWidgetList(
                            homeScreenController.fixedContent,
                          )
                        ]
                      : [const HomeShimmer()];
                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: 90, top: topPadding),
                    itemCount: items.length,
                    itemBuilder: (context, index) => items[index],
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
            Obx(() {
              final libSongsController = Get.find<LibrarySongsController>();
              return SortWidget(
                tag: "LibSongSort",
                itemCountTitle:
                    "${libSongsController.cachedSongsList.length} items",
                titleLeftPadding: 9,
                isDateOptionRequired: true,
                isDurationOptionRequired: true,
                isSearchFeatureRequired: true,
                onSort: (p0, p1, p2, p3) {
                  libSongsController.onSort(p0, p1, p2, p3);
                },
                onSearch: libSongsController.onSearch,
                onSearchClose: libSongsController.onSearchClose,
                onSearchStart: libSongsController.onSearchStart,
              );
            }),
            GetX<LibrarySongsController>(builder: (controller) {
              return controller.cachedSongsList.isNotEmpty
                  ? ListWidget(
                      controller.cachedSongsList,
                      "Library Songs",
                      true,
                      isPlaylist: true,
                      playlist: Playlist(
                          title: "Cached/Offline",
                          playlistId: "SongsCache",
                          thumbnailUrl: "",
                          isCloudPlaylist: false),
                    )
                  : Expanded(
                      child: Center(
                          child: Text(
                        "No Offline Songs!",
                        style: Theme.of(context).textTheme.titleMedium,
                      )),
                    );
            })
          ],
        ),
      );
    } else if (homeScreenController.tabIndex.value == 2) {
      return const PlaylistNAlbumLibraryWidget(isAlbumContent: false);
    } else if (homeScreenController.tabIndex.value == 3) {
      return const PlaylistNAlbumLibraryWidget();
    } else if (homeScreenController.tabIndex.value == 4) {
      return const LibraryArtistWidget();
    } else if (homeScreenController.tabIndex.value == 5) {
      return const SettingsScreen();
    } else {
      return Center(
        child: Text("${homeScreenController.tabIndex.value}"),
      );
    }
  }

  List<Widget> getWidgetList(dynamic list) {
    return list
        .map((content) => ContentListWidget(content: content))
        .whereType<Widget>()
        .toList();
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
          Obx(
            () => SortWidget(
              tag: "LibArtistSort",
              isSearchFeatureRequired: true,
              itemCountTitle: "${cntrller.libraryArtists.length} items",
              onSort: (sortByName, sortByDate, sortByDuration, isAscending) {
                cntrller.onSort(sortByName, isAscending);
              },
              onSearch: cntrller.onSearch,
              onSearchClose: cntrller.onSearchClose,
              onSearchStart: cntrller.onSearchStart,
            ),
          ),
          Obx(() => cntrller.libraryArtists.isNotEmpty
              ? ListWidget(cntrller.libraryArtists, "Library Artists", true)
              : Expanded(
                  child: Center(
                      child: Text(
                  "No Bookmarks!",
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
    final settingscrnController = Get.find<SettingsScreenController>();
    var size = MediaQuery.of(context).size;

    const double itemHeight = 220;
    const double itemWidth = 180;

    return Padding(
      padding: const EdgeInsets.only(top: 90.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isAlbumContent ? "Library Albums" : "Library Playlists",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                (isAlbumContent ||
                        settingscrnController.isLinkedWithPiped.isFalse)
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(right: size.width * .05),
                        child: RotationTransition(
                          turns: Tween(begin: 0.0, end: 1.0)
                              .animate(librplstCntrller.controller),
                          child: IconButton(
                              splashRadius: 20,
                              iconSize: 20,
                              visualDensity: const VisualDensity(vertical: -4),
                              icon: const Icon(
                                Icons.sync,
                              ), // <-- Icon
                              onPressed: () async {
                                printINFO(librplstCntrller.controller.status);
                                librplstCntrller.controller.forward();
                                librplstCntrller.controller.repeat();
                                await librplstCntrller.syncPipedPlaylist();
                                librplstCntrller.controller.stop();
                                librplstCntrller.controller.reset();
                              }),
                        ),
                      )
              ],
            ),
          ),
          Obx(
            () => isAlbumContent
                ? SortWidget(
                  tag: "LibAlbumSort",
                    isSearchFeatureRequired: true,
                    itemCountTitle:
                        "${libralbumCntrller.libraryAlbums.length} items",
                    isDateOptionRequired: isAlbumContent,
                    onSort: (a, b, c, d) {
                      libralbumCntrller.onSort(a, b, d);
                    },
                    onSearch: libralbumCntrller.onSearch,
                    onSearchClose: libralbumCntrller.onSearchClose,
                    onSearchStart: libralbumCntrller.onSearchStart,
                  )
                : SortWidget(
                  tag: "LibPlaylistSort",
                    isSearchFeatureRequired: true,
                    itemCountTitle:
                        "${librplstCntrller.libraryPlaylists.length} items",
                    isDateOptionRequired: isAlbumContent,
                    onSort: (a, b, c, d) {
                      librplstCntrller.onSort(a, d);
                    },
                    onSearch: librplstCntrller.onSearch,
                    onSearchClose: librplstCntrller.onSearchClose,
                    onSearchStart: librplstCntrller.onSearchStart,
                  ),
          ),
          Expanded(
            child: Obx(
              () => (isAlbumContent
                      ? libralbumCntrller.libraryAlbums.isNotEmpty
                      : librplstCntrller.libraryPlaylists.isNotEmpty)
                  ? GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ((size.width - 60) / itemWidth).ceil(),
                        childAspectRatio: (itemWidth / itemHeight),
                      ),
                      controller: ScrollController(keepScrollOffset: false),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.only(bottom: 70, top: 10),
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
                      "No Bookmarks!",
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
            ),
          )
        ],
      ),
    );
  }
}
