import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/artist_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/image_widget.dart';
import 'package:harmonymusic/ui/widgets/search_related_widgets.dart';

import '../navigator.dart';
import '../widgets/snackbar.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final ArtistScreenController artistScreenController = args != null
        ? Get.put(ArtistScreenController(args[0], args[1]))
        : Get.find<ArtistScreenController>();
    return Scaffold(
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
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).textTheme.titleMedium!.color,
                      ),
                      onPressed: () {
                        Get.nestedKey(ScreenNavigationSetup.id)!
                            .currentState!
                            .pop();
                      },
                    ),
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
              final content = artistScreenController.artistData;
              switch (artistScreenController.navigationRailCurrentIndex.value) {
                case 0:
                  {
                    return artistScreenController.isArtistContentFetced.isTrue? Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 90, top: 70),
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
                                            child: ClipOval(
                                              child: SizedBox(
                                                height: 200,
                                                width: 200,
                                                child: ImageWidget(
                                                    artist:
                                                        artistScreenController
                                                            .artist_,
                                                    isLargeImage: true),
                                              ),
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
                                                  ? const SizedBox.shrink()
                                                  : Icon(artistScreenController
                                                          .isAddedToLibrary
                                                          .isFalse
                                                      ? Icons.bookmark_add
                                                      : Icons.bookmark_added),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      child: Text(
                                        artistScreenController.artist_.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    (content.containsKey("description") &&
                                            content["description"] != null)
                                        ? Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "\"${content["description"]}\"",
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
                    ):const Center(child: RefreshProgressIndicator(),);
                  }
                case 1:
                  {
                    return SeparateSearchItemWidget(
                      isResultWidget: false,
                      items: content.containsKey('songs')
                          ? content['songs']['results']
                          : [],
                      title: "Songs",
                      topPadding: 75,
                    );
                  }
                case 2:
                  {
                    return SeparateSearchItemWidget(
                      isResultWidget: false,
                      items: content.containsKey('videos')
                          ? content['videos']['results']
                          : [],
                      title: "Videos",
                      topPadding: 75,
                    );
                  }
                case 3:
                  {
                    return SeparateSearchItemWidget(
                      isResultWidget: false,
                      items: content.containsKey('albums')
                          ? content['albums']['results']
                          : [],
                      title: "Albums",
                      topPadding: 75,
                    );
                  }
                case 4:
                  {
                    return SeparateSearchItemWidget(
                      isResultWidget: false,
                      items: content.containsKey('singles')
                          ? content['singles']['results']
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
