import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../navigator.dart';
import '../widgets/loader.dart';
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
            child: Obx(
              () => ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: searchResScrController.railitemHeight.value),
                child: IntrinsicHeight(
                  child: Obx(
                    () => NavigationRail(
                      onDestinationSelected:
                          searchResScrController.onDestinationSelected,
                      minWidth: 60,
                      destinations: (searchResScrController
                                  .isResultContentFetced.value &&
                              searchResScrController.railItems.isNotEmpty)
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
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
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
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                      labelType: NavigationRailLabelType.all,
                      selectedIndex: searchResScrController
                          .navigationRailCurrentIndex.value,
                    ),
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
                  if (searchResScrController.isResultContentFetced.isTrue &&
                      searchResScrController.railItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No Match found for",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text("'${searchResScrController.queryString.value}'"),
                        ],
                      ),
                    );
                  } else if (searchResScrController
                      .isResultContentFetced.isTrue) {
                    return const ResultWidget();
                  } else {
                    return const Center(
                      child: LoadingIndicator(),
                    );
                  }
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
                          items: const [],
                          title: name,
                          isCompleteList: true,
                          topPadding: 75,
                          scrollController:
                              searchResScrController.scrollControllers[name],
                        );
                      }
                    case "Featured playlists":
                    case "Community playlists":
                      {
                        return SeparateSearchItemWidget(
                          title: name,
                          items: const [],
                          topPadding: 75,
                          scrollController:
                              searchResScrController.scrollControllers[name],
                        );
                      }
                    case "Albums":
                      {
                        return SeparateSearchItemWidget(
                          title: name,
                          items: const [],
                          topPadding: 75,
                          scrollController:
                              searchResScrController.scrollControllers[name],
                        );
                      }
                    case "Artists":
                      {
                        return SeparateSearchItemWidget(
                          title: name,
                          items: const [],
                          topPadding: 75,
                          scrollController:
                              searchResScrController.scrollControllers[name],
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
