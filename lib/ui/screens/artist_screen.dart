import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/artist_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/image_widget.dart';
import 'package:harmonymusic/ui/widgets/search_related_widgets.dart';

import '../navigator.dart';
import '../widgets/snackbar.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final args = Get.arguments;
    final ArtistScreenController artistScreenController =
        Get.isRegistered<ArtistScreenController>()
            ? Get.find<ArtistScreenController>()
            : Get.put(ArtistScreenController(args[0], args[1]));
    return Scaffold(
      floatingActionButton: Obx(
        () => Padding(
          padding: EdgeInsets.only(
              bottom:
                  playerController.playerPanelMinHeight.value == 0 ? 20 : 75),
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
                    final radioId = artistScreenController.artist_.radioId;
                    if (radioId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(snackbar(
                          context, "Radio not available for this artist!",
                          size: SanckBarSize.BIG));
                      return;
                    }
                    playerController.startRadio(null,
                        playlistid: artistScreenController.artist_.radioId);
                  },
                  child: const Icon(Icons.sensors_rounded)),
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          Obx(
            () => NavigationRail(
              onDestinationSelected:
                  artistScreenController.onDestinationSelected,
              minWidth: 60,
              destinations: [
                railDestination("About"),
                railDestination("Songs"),
                railDestination('Videos'),
                railDestination("Albums"),
                railDestination("Singles"),
              ],
              leading: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Theme.of(context).textTheme.titleMedium!.color,
                    ),
                    onPressed: () {
                      Get.nestedKey(ScreenNavigationSetup.id)!
                          .currentState!
                          .pop();
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
              labelType: NavigationRailLabelType.all,
              selectedIndex:
                  artistScreenController.navigationRailCurrentIndex.value,
            ),
          ),
          Expanded(child: Obx(
            () {
              final artistData = artistScreenController.artistData;
              final separatedContent = artistScreenController.sepataredContent;

              if (artistScreenController
                      .isSeparatedArtistContentFetced.isFalse &&
                  artistScreenController.navigationRailCurrentIndex.value !=
                      0) {
                return const Center(child: RefreshProgressIndicator());
              }

              switch (artistScreenController.navigationRailCurrentIndex.value) {
                case 0:
                  {
                    return artistScreenController.isArtistContentFetced.isTrue
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                padding:
                                    const EdgeInsets.only(bottom: 90, top: 70),
                                child: artistScreenController
                                        .isArtistContentFetced.value
                                    ? Column(
                                        children: [
                                          SizedBox(
                                            height: 200,
                                            width: 250,
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: ImageWidget(
                                                    size: 200,
                                                    artist:
                                                        artistScreenController
                                                            .artist_,
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: InkWell(
                                                    onTap: () {
                                                      final bool add =
                                                          artistScreenController
                                                              .isAddedToLibrary
                                                              .isFalse;
                                                      artistScreenController
                                                          .addNremoveFromLibrary(
                                                              add: add)
                                                          .then((value) => ScaffoldMessenger
                                                                  .of(context)
                                                              .showSnackBar(snackbar(
                                                                  context,
                                                                  value
                                                                      ? add
                                                                          ? "Artist bookmarked !"
                                                                          : "Artist bookmark removed!"
                                                                      : "Operation failed",
                                                                  size: SanckBarSize.MEDIUM)));
                                                    },
                                                    child: artistScreenController
                                                            .isArtistContentFetced
                                                            .isFalse
                                                        ? const SizedBox
                                                            .shrink()
                                                        : Icon(artistScreenController
                                                                .isAddedToLibrary
                                                                .isFalse
                                                            ? Icons
                                                                .bookmark_add_rounded
                                                            : Icons
                                                                .bookmark_added_rounded),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: Text(
                                              artistScreenController
                                                  .artist_.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                          (artistData.containsKey(
                                                      "description") &&
                                                  artistData["description"] !=
                                                      null)
                                              ? Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "\"${artistData["description"]}\"",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall,
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: 300,
                                                  child: Center(
                                                    child: Text(
                                                      "No description available!",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          )
                        : const Center(
                            child: RefreshProgressIndicator(),
                          );
                  }
                case 1:
                  {
                    return SeparateSearchItemWidget(
                      isResultWidget: false,
                      items: separatedContent.containsKey('Songs')
                          ? separatedContent['Songs']['results']
                          : [],
                      title: "Songs",
                      topPadding: 75,
                      scrollController:
                          artistScreenController.songScrollController,
                    );
                  }
                case 2:
                  {
                    return SeparateSearchItemWidget(
                      isResultWidget: false,
                      items: separatedContent.containsKey('Videos')
                          ? separatedContent['Videos']['results']
                          : [],
                      title: "Videos",
                      topPadding: 75,
                      scrollController:
                          artistScreenController.videoScrollController,
                    );
                  }
                case 3:
                  {
                    return SeparateSearchItemWidget(
                      isResultWidget: false,
                      items: separatedContent.containsKey('Albums')
                          ? separatedContent['Albums']['results']
                          : [],
                      title: "Albums",
                      topPadding: 75,
                    );
                  }
                case 4:
                  {
                    return SeparateSearchItemWidget(
                      isResultWidget: false,
                      items: separatedContent.containsKey('Singles')
                          ? separatedContent['Singles']['results']
                          : [],
                      title: "Singles",
                      topPadding: 75,
                    );
                  }
              }
              return const SizedBox.shrink();
            },
          ))
        ],
      ),
    );
  }

  NavigationRailDestination railDestination(String label) {
    return NavigationRailDestination(
      icon: const SizedBox.shrink(),
      label: RotatedBox(quarterTurns: -1, child: Text(label)),
    );
  }
}
