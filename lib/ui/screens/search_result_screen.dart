import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/widgets/shimmer_widgets/song_list_shimmer.dart';

import '../widgets/search_related_widgets.dart';
import 'search_result_screen_controller.dart';

class SearchResultScreen extends StatelessWidget {
  const SearchResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchResScrController = Get.put(SearchResultScreenController());
    return Scaffold(
      body: Row(
        children: [
          Obx(
            () => NavigationRail(
              onDestinationSelected:
                  searchResScrController.onDestinationSelected,
              minWidth: 60,
              destinations: searchResScrController.isResultContentFetced.value
                  ? [
                      railDestination("Results"),
                      ...(searchResScrController.railItems
                          .map((element) => railDestination(element))),
                    ]
                  : [railDestination("Results"), railDestination("")],
              leading: const SizedBox(height: 60),
              labelType: NavigationRailLabelType.all,
              selectedIndex:
                  searchResScrController.navigationRailCurrentIndex.value,
            ),
          ),
          Expanded(
            child: Obx(
              () {
                if (searchResScrController.navigationRailCurrentIndex.value ==
                    0) {
                  return const ResultWidget();
                }
                if (searchResScrController.isResultContentFetced.isTrue) {
                  final name = searchResScrController.railItems[
                      searchResScrController.navigationRailCurrentIndex.value -
                          1];
                  switch (name) {
                    case "Songs":
                    case "Videos":
                      {
                        return searchResScrController
                                .isSeparatedResultContentFetced.isTrue
                            ? SeparateSearchItemWidget(
                                items: searchResScrController
                                    .separatedResultContent[name],
                                title: name,
                                isCompleteList: true,
                                topPadding: 75,
                              )
                            : const SongListShimmer(
                                topPadding: 140,
                              );
                      }
                    case "Featured playlists":
                    case "Community playlists":
                      {
                        return searchResScrController
                                .isSeparatedResultContentFetced.isTrue
                            ? SeparateSearchItemWidget(
                                title: name,
                                items: searchResScrController
                                    .separatedResultContent[name],
                                topPadding: 75,
                              )
                            : const SizedBox.shrink();
                      }
                    case "Albums":
                      {
                        return searchResScrController
                                .isSeparatedResultContentFetced.isTrue
                            ? SeparateSearchItemWidget(
                                title: name,
                                items: searchResScrController
                                    .separatedResultContent[name],
                                topPadding: 75,
                              )
                            : const SizedBox.shrink();
                      }
                    case "Artists":
                      {
                        return searchResScrController
                                .isSeparatedResultContentFetced.isTrue
                            ? SeparateSearchItemWidget(
                                title: name,
                                items: searchResScrController
                                    .separatedResultContent[name],
                                topPadding: 75,
                              )
                            : const SizedBox.shrink();
                      }
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          )
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
