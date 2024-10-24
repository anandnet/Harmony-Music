import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/screens/Search/search_result_screen_controller.dart';
import 'package:harmonymusic/ui/screens/Search/search_result_screen_v2.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/animated_screen_transition.dart';
import 'package:harmonymusic/ui/widgets/loader.dart';
import 'package:harmonymusic/ui/widgets/search_related_widgets.dart';
import 'package:harmonymusic/ui/widgets/separate_tab_item_widget.dart';

class SearchResultScreen extends StatelessWidget {
  const SearchResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchResScrController = Get.put(SearchResultScreenController());
    return GetPlatform.isDesktop || Get.find<SettingsScreenController>().isBottomNavBarEnabled.isTrue
        ? const SearchResultScreenBN()
        : Scaffold(
            body: row.children([
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: IntrinsicHeight(
                    child: Obx(
                      () => NavigationRail(
                        onDestinationSelected: searchResScrController.onDestinationSelected,
                        minWidth: 60,
                        destinations: (searchResScrController.isResultContentFetced.value &&
                                searchResScrController.railItems.isNotEmpty)
                            ? [
                                railDestination('results'.tr),
                                ...(searchResScrController.railItems.map(railDestination)),
                              ]
                            : [railDestination('results'.tr), railDestination('')],
                        leading: column.children([
                          SizedBox(height: context.isLandscape ? 20 : 45),
                          IconButton(
                            icon: Icons.arrow_back_ios_new_rounded.icon
                                .color(Theme.of(context).textTheme.titleMedium!.color)
                                .mk,
                            onPressed: () {
                              Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
                            },
                          ),
                          const SizedBox(height: 10),
                        ]),
                        labelType: NavigationRailLabelType.all,
                        selectedIndex: searchResScrController.navigationRailCurrentIndex.value,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GetX<SearchResultScreenController>(
                  builder: (controller) => AnimatedScreenTransition(
                    enabled: Get.find<SettingsScreenController>().isTransitionAnimationDisabled.isFalse,
                    resverse: controller.isTabTransitionReversed,
                    child: Center(
                      key: ValueKey<int>(controller.navigationRailCurrentIndex.toInt() * 8),
                      child: Body(searchResScrController: searchResScrController),
                    ),
                  ),
                ),
              )
            ]),
          );
  }

  NavigationRailDestination railDestination(String label) {
    return NavigationRailDestination(
      icon: const SizedBox.shrink(),
      label: RotatedBox(quarterTurns: -1, child: Text(label.toLowerCase().removeAllWhitespace.tr)),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    required this.searchResScrController,
    super.key,
  });

  final SearchResultScreenController searchResScrController;

  @override
  Widget build(BuildContext context) {
    if (searchResScrController.navigationRailCurrentIndex.value == 0) {
      return Obx(() {
        if (searchResScrController.isResultContentFetced.isTrue && searchResScrController.railItems.isEmpty) {
          return Center(
              child: column.center.children([
            Text(
              'nomatch'.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            searchResScrController.queryString.value.text.mk,
          ]));
        } else if (searchResScrController.isResultContentFetced.isTrue) {
          return const ResultWidget();
        } else {
          return const Center(
            child: LoadingIndicator(),
          );
        }
      });
    } else {
      if (searchResScrController.isResultContentFetced.isTrue) {
        final topPadding = context.isLandscape ? 50.0 : 80.0;
        final name = searchResScrController.railItems[searchResScrController.navigationRailCurrentIndex.value - 1];
        return SeparateTabItemWidget(
          items: const [],
          title: name,
          topPadding: topPadding,
          scrollController: searchResScrController.scrollControllers[name],
        );
      }
    }
    return const SizedBox.shrink();
  }
}
