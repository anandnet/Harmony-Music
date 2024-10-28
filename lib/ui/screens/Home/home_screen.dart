import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/res/tailwind_ext.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';
import 'package:harmonymusic/ui/screens/Library/library.dart';
import 'package:harmonymusic/ui/screens/Library/library_combined.dart';
import 'package:harmonymusic/ui/screens/Search/components/desktop_search_bar.dart';
import 'package:harmonymusic/ui/screens/Search/search_screen.dart';
import 'package:harmonymusic/ui/screens/Search/search_screen_controller.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/animated_screen_transition.dart';
import 'package:harmonymusic/ui/widgets/content_list_widget.dart';
import 'package:harmonymusic/ui/widgets/create_playlist_dialog.dart';
import 'package:harmonymusic/ui/widgets/quickpickswidget.dart';
import 'package:harmonymusic/ui/widgets/shimmer_widgets/home_shimmer.dart';
import 'package:harmonymusic/ui/widgets/side_nav_bar.dart';

import '../../widgets/sliding_up_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final homeScreenController = Get.find<HomeScreenController>();
    final settingsScreenController = Get.find<SettingsScreenController>();

    return Scaffold(
      floatingActionButton: Obx(
        () => ((homeScreenController.tabIndex.value == 0 && !GetPlatform.isDesktop) ||
                    homeScreenController.tabIndex.value == 2) &&
                settingsScreenController.isBottomNavBarEnabled.isFalse
            ? Obx(
                () => Padding(
                  padding: EdgeInsets.only(bottom: playerController.playerPanelMinHeight.value),
                  child: sizedBox.s110.child(
                    FittedBox(
                      child: FloatingActionButton(
                        focusElevation: 0,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                        elevation: 0,
                        onPressed: () async {
                          if (homeScreenController.tabIndex.value == 2) {
                            showDialog(context: context, builder: (context) => const CreateNRenamePlaylistPopup());
                          } else {
                            Get.toNamed(ScreenNavigationSetup.searchScreen, id: ScreenNavigationSetup.id);
                          }
                        },
                        child: (homeScreenController.tabIndex.value == 2 ? Icons.add : Icons.search_rounded).icon.mk,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
      body: Obx(
        () => row.children([
          // create a navigation rail
          if (settingsScreenController.isBottomNavBarEnabled.isFalse)
            const SideNavBar()
          else
            const SizedBox(
              width: 0,
            ),
          //const VerticalDivider(thickness: 1, width: 2),
          Expanded(
            child: Obx(() => AnimatedScreenTransition(
                enabled: settingsScreenController.isTransitionAnimationDisabled.isFalse,
                resverse: homeScreenController.reverseAnimationTransition,
                horizontalTransition: settingsScreenController.isBottomNavBarEnabled.isTrue,
                child: Center(
                  key: ValueKey<int>(homeScreenController.tabIndex.value),
                  child: const Body(),
                ))),
          ),
        ]),
      ),
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
    final settingsScreenController = Get.find<SettingsScreenController>();
    final size = MediaQuery.of(context).size;
    final leftPadding = settingsScreenController.isBottomNavBarEnabled.isTrue ? 20.0 : 5.0;
    final topPadding = GetPlatform.isDesktop
        ? 85.0
        : context.isLandscape
            ? 50.0
            : size.height < 750
                ? 80.0
                : 85.0;
    if (homeScreenController.tabIndex.value == 0) {
      return Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                // for Desktop search bar
                if (GetPlatform.isDesktop) {
                  final searchScreenCtrl = Get.find<SearchScreenController>();
                  if (searchScreenCtrl.focusNode.hasFocus) {
                    searchScreenCtrl.focusNode.unfocus();
                  }
                }
              },
              child: Obx(
                () => homeScreenController.networkError.isTrue
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height - 180,
                        child: column.children([
                          Align(
                            alignment: Alignment.topLeft,
                            child: 'home'.tr.text.titleLarge.mk,
                          ),
                          Expanded(
                            child: Center(
                              child: column.center.children([
                                'networkError1'.tr.text.titleMedium.mk,
                                const SizedBox(height: 10),
                                container.ph30.pv30.rounded20
                                    .color(Theme.of(context).textTheme.titleLarge!.color)
                                    .child(
                                      InkWell(
                                        onTap: homeScreenController.loadContentFromNetwork,
                                        child: 'retry'.tr.text.color(Theme.of(context).canvasColor).mk,
                                      ),
                                    )
                              ]),
                            ),
                          )
                        ]),
                      )
                    : Obx(() {
                        // dispose all detachached scroll controllers
                        homeScreenController.disposeDetachedScrollControllers();
                        final items = homeScreenController.isContentFetched.value
                            ? [
                                Obx(() {
                                  final scrollController = ScrollController();
                                  homeScreenController.contentScrollControllers.add(scrollController);
                                  return QuickPicksWidget(
                                      content: homeScreenController.quickPicks.value,
                                      scrollController: scrollController);
                                }),
                                ...getWidgetList(homeScreenController.middleContent, homeScreenController),
                                ...getWidgetList(homeScreenController.fixedContent, homeScreenController)
                              ]
                            : [const HomeShimmer()];
                        return ListView.builder(
                          padding: EdgeInsets.only(bottom: 200, top: topPadding),
                          itemCount: items.length,
                          itemBuilder: (context, index) => items[index],
                        );
                      }),
              ),
            ),
            if (GetPlatform.isDesktop)
              Align(
                alignment: Alignment.topCenter,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth > 800 ? 800 : constraints.maxWidth - 40,
                      child: padding.pt16.child(
                        const DesktopSearchBar(),
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      );
    } else if (homeScreenController.tabIndex.value == 1) {
      return settingsScreenController.isBottomNavBarEnabled.isTrue ? const SearchScreen() : const SongsLibraryWidget();
    } else if (homeScreenController.tabIndex.value == 2) {
      return settingsScreenController.isBottomNavBarEnabled.isTrue
          ? const CombinedLibrary()
          : const PlaylistNAlbumLibraryWidget(isAlbumContent: false);
    } else if (homeScreenController.tabIndex.value == 3) {
      return settingsScreenController.isBottomNavBarEnabled.isTrue
          ? const SettingsScreen(isBottomNavActive: true)
          : const PlaylistNAlbumLibraryWidget();
    } else if (homeScreenController.tabIndex.value == 4) {
      return const LibraryArtistWidget();
    } else if (homeScreenController.tabIndex.value == 5) {
      return const SettingsScreen();
    }

    ///
    else if (homeScreenController.tabIndex.value == 6) {
      // return const Text('Testing screen');
      BorderRadiusGeometry radius = const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      );
      return Scaffold(
        body: SlidingUpPanel(
          panel: const Center(
            child: Text('This is the sliding Widget'),
          ),
          collapsed: DecoratedBox(
            decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: radius),
            child: const Center(
              child: Icon(Icons.arrow_drop_down),
            ),
          ),
          minHeight: 300,
          // maxHeight: 300,
          body: const Center(
            child: Text('This is the Widget behind the sliding panel'),
          ),
          borderRadius: radius,
        ),
      );
    }

    ///
    else {
      return Center(
        child: 'Screen Index: ${homeScreenController.tabIndex.value}'.text.mk,
      );
    }
  }

  List<Widget> getWidgetList(dynamic list, HomeScreenController homeScreenController) {
    return list
        .map((content) {
          final scrollController = ScrollController();
          homeScreenController.contentScrollControllers.add(scrollController);
          return ContentListWidget(content: content, scrollController: scrollController);
        })
        .whereType<Widget>()
        .toList();
  }
}
