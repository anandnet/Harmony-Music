import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '/ui/player/components/gesture_player.dart';
import '/ui/player/components/standard_player.dart';
import '/ui/screens/Settings/settings_screen_controller.dart';
import '../../utils/helper.dart';
import '../widgets/snackbar.dart';
import '../widgets/up_next_queue.dart';
import '/ui/player/player_controller.dart';
import '../widgets/sliding_up_panel.dart';

/// Player screen
/// Contains the player ui
///
/// Player ui can be standard player or gesture player
class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    printINFO("player");
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();
    final settingsScreenController = Get.find<SettingsScreenController>();
    return Scaffold(
      /// SlidingUpPanel is used to create a panel that can slide up and down
      /// It is used to show the current queue panel in mobile
      body: Obx(
        () => SlidingUpPanel(
          boxShadow: const [],
          minHeight: settingsScreenController.playerUi.value == 0
              ? 65 + Get.mediaQuery.padding.bottom
              : 0,
          maxHeight: size.height,
          isDraggable: !GetPlatform.isDesktop,
          controller: GetPlatform.isDesktop
              ? null
              : playerController.queuePanelController,

          /// this is the header of the collapsed panel
          /// contains the button ^ to open the queue panel
          collapsed: InkWell(
            onTap: () {
              /// queue open in end drawer in desktop
              if (GetPlatform.isDesktop) {
                playerController.homeScaffoldkey.currentState!.openEndDrawer();
              } else {
                playerController.queuePanelController.open();
              }
            },
            child: Container(
                color: Theme.of(context).primaryColor,
                child: Column(
                  children: [
                    SizedBox(
                      height: 65,
                      child: Center(
                          child: Icon(
                        color: Theme.of(context).textTheme.titleMedium!.color,
                        Icons.keyboard_arrow_up,
                        size: 40,
                      )),
                    ),
                  ],
                )),
          ),

          /// Panel for queue
          panelBuilder: (ScrollController sc, onReorderStart, onReorderEnd) {
            playerController.scrollController = sc;
            return Stack(
              children: [
                /// Stack first child
                /// UpNextQueue widget contains list of songs in queue
                UpNextQueue(
                  onReorderEnd: onReorderEnd,
                  onReorderStart: onReorderStart,
                ),

                /// Stack second child
                /// This contains the bottom bar with queue loop, shuffle, clear queue buttons
                /// and number of songs in queue
                /// BackdropFilter is used to blur the background
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 10, left: 10, right: 10),
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(blurRadius: 5, color: Colors.black54)
                            ],
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.5)),
                        height: 60 + Get.mediaQuery.padding.bottom,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              /// number of songs in queue
                              Obx(
                                () => Text(
                                  "${playerController.currentQueue.length} ${"songs".tr}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .color),
                                ),
                              ),

                              /// queue loop button
                              InkWell(
                                onTap: () {
                                  playerController.toggleQueueLoopMode();
                                },
                                child: Obx(
                                  () => Container(
                                    height: 30,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    decoration: BoxDecoration(
                                      color: playerController
                                              .isQueueLoopModeEnabled.isFalse
                                          ? Colors.white24
                                          : Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(child: Text("queueLoop".tr)),
                                  ),
                                ),
                              ),

                              /// queue shuffle button
                              InkWell(
                                onTap: () {
                                  if (playerController
                                      .isShuffleModeEnabled.isTrue) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        snackbar(context,
                                            "queueShufflingDeniedMsg".tr,
                                            size: SanckBarSize.BIG));
                                    return;
                                  }
                                  playerController.shuffleQueue();
                                },
                                child: Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                      child: Icon(Icons.shuffle,
                                          color: Colors.black)),
                                ),
                              ),

                              /// clear queue button
                              InkWell(
                                onTap: () {
                                  playerController.clearQueue();
                                },
                                child: Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                      child: Icon(Icons.playlist_remove,
                                          color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },

          /// show player ui based on selected player ui in settings
          /// Gesture player is only applicable for mobile
          body: settingsScreenController.playerUi.value == 0
              ? const StandardPlayer()
              : const GesturePlayer(),
        ),
      ),
    );
  }
}
