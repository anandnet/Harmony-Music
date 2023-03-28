import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              destinations: searchResScrController.isResultContentFetced.value
                  ? [
                      railDestination("Results"),
                      ...(searchResScrController.railItems
                          .map((element) => railDestination(element))),
                    ]
                  : [
                      railDestination("Results"),
                      railDestination("")
                    ],
              leading: const SizedBox(height: 60),
              labelType: NavigationRailLabelType.all,
              selectedIndex:
                  searchResScrController.navigationRailCurrentIndex.value,
            ),
          ),
          Expanded(child: Obx(() {
            if (searchResScrController.navigationRailCurrentIndex.value == 0) {
              return const ResultWidget();
            } else {
              return const SizedBox.shrink();
            }
          }))
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
