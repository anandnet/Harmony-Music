import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../navigator.dart';
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
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height + 195),
              child: IntrinsicHeight(
                child: Obx(
                  () => NavigationRail(
                    onDestinationSelected:
                        searchResScrController.onDestinationSelected,
                    minWidth: 60,
                    destinations: searchResScrController
                            .isResultContentFetced.value
                        ? [
                            railDestination("Results"),
                            ...(searchResScrController.railItems
                                .map((element) => railDestination(element))),
                          ]
                        : [railDestination("Results"), railDestination("")],
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
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .color,
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
                        searchResScrController.navigationRailCurrentIndex.value,
                  ),
                ),
              ),
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
                        return SeparateSearchItemWidget(
                          isResultWidget: true,
                          items: [],
                          title: name,
                          isCompleteList: true,
                          topPadding: 75,
                        );
                      }
                    case "Featured playlists":
                    case "Community playlists":
                      {
                        return SeparateSearchItemWidget(
                          title: name,
                          items: [],
                          topPadding: 75,
                        );
                      }
                    case "Albums":
                      {
                        return SeparateSearchItemWidget(
                          title: name,
                          items: [],
                          topPadding: 75,
                        );
                      }
                    case "Artists":
                      {
                        return SeparateSearchItemWidget(
                          title: name,
                          items: [],
                          topPadding: 75,
                        );
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
