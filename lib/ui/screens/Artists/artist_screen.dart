import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/res/tailwind_ext.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/Artists/artist_screen_controller.dart';
import 'package:harmonymusic/ui/screens/Artists/artist_screen_v2.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/animated_screen_transition.dart';
import 'package:harmonymusic/ui/widgets/image_widget.dart';
import 'package:harmonymusic/ui/widgets/loader.dart';
import 'package:harmonymusic/ui/widgets/separate_tab_item_widget.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';
import 'package:share_plus/share_plus.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final tag = key.hashCode.toString();
    final artistScreenController = Get.isRegistered<ArtistScreenController>(tag: tag)
        ? Get.find<ArtistScreenController>(tag: tag)
        : Get.put(ArtistScreenController(), tag: tag);
    return Scaffold(
      floatingActionButton: Obx(
        () => Padding(
          padding: EdgeInsets.only(bottom: playerController.playerPanelMinHeight.value),
          child: SizedBox(
            height: 60,
            width: 60,
            child: FittedBox(
              child: FloatingActionButton(
                  focusElevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  elevation: 0,
                  onPressed: () async {
                    final radioId = artistScreenController.artist_.radioId;
                    if (radioId == null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(snackbar(context, 'radioNotAvailable'.tr, size: SanckBarSize.BIG));
                      return;
                    }
                    playerController.startRadio(null, playlistid: artistScreenController.artist_.radioId);
                  },
                  child: const Icon(Icons.sensors_rounded)),
            ),
          ),
        ),
      ),
      body: GetPlatform.isDesktop || Get.find<SettingsScreenController>().isBottomNavBarEnabled.value
          ? ArtistScreenBN(artistScreenController: artistScreenController, tag: tag)
          : Row(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: IntrinsicHeight(
                      child: Obx(
                        () => NavigationRail(
                          onDestinationSelected: artistScreenController.onDestinationSelected,
                          minWidth: 60,
                          destinations: ['about'.tr, 'songs'.tr, 'videos'.tr, 'albums'.tr, 'singles'.tr]
                              .map(railDestination)
                              .toList(),
                          leading: column.children([
                            SizedBox(
                              height: context.isLandscape ? 20.0 : 45.0,
                            ),
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
                          selectedIndex: artistScreenController.navigationRailCurrentIndex.value,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => AnimatedScreenTransition(
                      enabled: Get.find<SettingsScreenController>().isTransitionAnimationDisabled.isFalse,
                      resverse: artistScreenController.isTabTransitionReversed,
                      child: Center(
                        key: ValueKey<int>(artistScreenController.navigationRailCurrentIndex.value),
                        child: Body(tag: tag),
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
      label: RotatedBox(quarterTurns: -1, child: Text(label)),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    required this.tag,
    super.key,
  });

  final String tag;

  @override
  Widget build(BuildContext context) {
    final artistScreenController = Get.find<ArtistScreenController>(tag: tag);

    final tabIndex = artistScreenController.navigationRailCurrentIndex.value;

    if (tabIndex == 0) {
      return Obx(() => artistScreenController.isArtistContentFetced.isTrue
          ? AboutArtist(
              artistScreenController: artistScreenController,
            )
          : const Center(
              child: LoadingIndicator(),
            ));
    } else {
      final separatedContent = artistScreenController.sepataredContent;
      final currentTabName = ['About', 'Songs', 'Videos', 'Albums', 'Singles'][tabIndex];
      return Obx(() {
        if (artistScreenController.isSeparatedArtistContentFetced.isFalse &&
            artistScreenController.navigationRailCurrentIndex.value != 0) {
          return const Center(child: LoadingIndicator());
        }
        return SeparateTabItemWidget(
          artistControllerTag: tag,
          isResultWidget: false,
          items: separatedContent.containsKey(currentTabName) ? separatedContent[currentTabName]['results'] : [],
          title: currentTabName,
          topPadding: context.isLandscape ? 50.0 : 80.0,
          scrollController: currentTabName == 'Songs'
              ? artistScreenController.songScrollController
              : currentTabName == 'Videos'
                  ? artistScreenController.videoScrollController
                  : null,
        );
      });
    }
  }
}

class AboutArtist extends StatelessWidget {
  const AboutArtist(
      {super.key, required this.artistScreenController, this.padding = const EdgeInsets.only(bottom: 90, top: 70)});

  final EdgeInsetsGeometry padding;
  final ArtistScreenController artistScreenController;

  @override
  Widget build(BuildContext context) {
    final artistData = artistScreenController.artistData;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          padding: padding,
          child: artistScreenController.isArtistContentFetced.value
              ? column.children([
                  container.h400.child(
                    Stack(children: [
                      Center(
                        child: ImageWidget(
                          size: 200,
                          artist: artistScreenController.artist_,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: column.children([
                          InkWell(
                              onTap: () {
                                final add = artistScreenController.isAddedToLibrary.isFalse;
                                artistScreenController.addNremoveFromLibrary(add: add).then((value) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      snackbar(
                                          context,
                                          value
                                              ? add
                                                  ? 'artistBookmarkAddAlert'.tr
                                                  : 'artistBookmarkRemoveAlert'.tr
                                              : 'operationFailed'.tr),
                                    );
                                  }
                                });
                              },
                              child: Obx(
                                () => artistScreenController.isArtistContentFetced.isFalse
                                    ? const SizedBox.shrink()
                                    : Icon(artistScreenController.isAddedToLibrary.isFalse
                                        ? Icons.bookmark_add_rounded
                                        : Icons.bookmark_added_rounded),
                              )),
                          IconButton(
                            icon: Icons.share.icon.s40.mk,
                            splashRadius: 18,
                            onPressed: () => Share.share(
                                'https://music.youtube.com/channel/${artistScreenController.artist_.browseId}'),
                          ),
                        ]),
                      )
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: artistScreenController.artist_.name.tr.text.titleLarge.mk,
                  ),
                  if (artistData.containsKey('description') && artistData['description'] != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: '"${artistData["description"]}"'.tr.text.titleSmall.mk,
                    )
                  else
                    sizedBox.h300.child(
                      Center(
                        child: 'artistDesNotAvailable'.tr.text.titleSmall.mk,
                      ),
                    ),
                ])
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
