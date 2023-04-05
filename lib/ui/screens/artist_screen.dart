import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/artist.dart';
import 'package:harmonymusic/ui/screens/artist_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/search_related_widgets.dart';

import '../navigator.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final artist = Get.arguments as Artist;
    final ArtistScreenController artistScreenController =
        Get.put(ArtistScreenController(artist));
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
                    return SizedBox.shrink();
                  }
                case 1:
                  {
                    if (content.containsKey('songs')) {
                      return SeparateSearchItemWidget(
                        items: content['songs']['results'],
                        title: "Songs",
                        topPadding: 75,
                      );
                    }
                    return SizedBox.shrink();
                  }
                case 2:
                  {
                    if (content.containsKey('videos')) {
                      return SeparateSearchItemWidget(
                        items: content['videos']['results'],
                        title: "Videos",
                        topPadding: 75,
                      );
                    }
                    return SizedBox.shrink();
                  }
                case 3:
                  {
                    if (content.containsKey('albums')) {
                      return SeparateSearchItemWidget(
                        items: content['albums']['results'],
                        title: "Albums",
                        topPadding: 75,
                      );
                    }
                    return SizedBox.shrink();
                  }
                case 4:
                  {
                    if (content.containsKey('singles')) {
                      return SeparateSearchItemWidget(
                        items: content['singles']['results'],
                        title: "Singles",
                        topPadding: 75,
                      );
                    }
                    return SizedBox.shrink();
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
