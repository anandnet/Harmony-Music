import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';

import '/ui/screens/Home/home_screen_controller.dart';
import '/ui/screens/Settings/settings_screen_controller.dart';
import '../utils/helper.dart';
import '../ui/navigator.dart';
import '../ui/player/player.dart';
import 'player/components/mini_player.dart';
import 'player/player_controller.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/scroll_to_hide.dart';
import 'widgets/sliding_up_panel.dart';
import 'widgets/snackbar.dart';
import 'widgets/up_next_queue.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  static const routeName = '/appHome';

  @override
  Widget build(BuildContext context) {
    printINFO("Home");
    final PlayerController playerController = Get.find<PlayerController>();
    final settingsScreenController = Get.find<SettingsScreenController>();
    final homeScreenController = Get.find<HomeScreenController>();
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 800;
    if (!playerController.initFlagForPlayer && settingsScreenController.isBottomNavBarEnabled.isFalse) {
      if (isWideScreen) {
        playerController.playerPanelMinHeight.value = 105 + Get.mediaQuery.padding.bottom;
      } else {
        playerController.playerPanelMinHeight.value = 75 + Get.mediaQuery.padding.bottom;
      }
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (playerController.playerPanelController.isPanelOpen) {
          playerController.playerPanelController.close();
        } else {
          if (Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.canPop()) {
            Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
          } else {
            if (playerController.buttonState.value == PlayButtonState.playing) {
              SystemNavigator.pop();
            } else {
              await Get.find<AudioHandler>().customAction("saveSession");
              exit(0);
            }
          }
        }
      },
      child: CallbackShortcuts(
        bindings: {LogicalKeySet(LogicalKeyboardKey.space): playerController.playPause},
        child: Obx(
          () => Scaffold(
            key: playerController.homeScaffoldkey,
            drawerScrimColor: Colors.transparent,
            endDrawer: GetPlatform.isDesktop || isWideScreen
                ? Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10)),
                      border: Border(
                        left: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        top: BorderSide(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    margin: const EdgeInsets.only(
                      top: 5,
                      bottom: 106,
                    ),
                    child: sizedBox.child(
                      column.children([
                        sizedBox.h60.child(
                          ColoredBox(
                            color: Theme.of(context).canvasColor,
                            child: Center(
                              child: padding.pl16.pr16.child(
                                row.spaceBetween.children([
                                  '${playerController.currentQueue.length} ${'songs'.tr}'.text.mk,
                                  Text(
                                    "upNext".tr,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  row.children(
                                    [
                                      InkWell(
                                        onTap: () {
                                          playerController.toggleQueueLoopMode();
                                        },
                                        child: Obx(
                                          () => Container(
                                            height: 30,
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: playerController.isQueueLoopModeEnabled.isFalse
                                                  ? Colors.white24
                                                  : Colors.white.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Center(child: Text("queueLoop".tr)),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.shuffle),
                                      )
                                    ],
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: UpNextQueue(
                            isQueueInSlidePanel: false,
                          ),
                        )
                      ]),
                    ),

                    /*
           child: SizedBox(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 60,
                            child: ColoredBox(
                              color: Theme.of(context).canvasColor,
                              child: Center(
                                  child: Padding(
                                padding: const EdgeInsets.only(left: 15.0, right: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${playerController.currentQueue.length} ${"songs".tr}"),
                                    Text(
                                      "upNext".tr,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            playerController.toggleQueueLoopMode();
                                          },
                                          child: Obx(
                                            () => Container(
                                              height: 30,
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              decoration: BoxDecoration(
                                                color: playerController.isQueueLoopModeEnabled.isFalse
                                                    ? Colors.white24
                                                    : Colors.white.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Center(child: Text("queueLoop".tr)),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              if (playerController.isShuffleModeEnabled.isTrue) {
                                                ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                                    context, "queueShufflingDeniedMsg".tr,
                                                    size: SanckBarSize.BIG));
                                                return;
                                              }
                                              playerController.shuffleQueue();
                                            },
                                            icon: const Icon(Icons.shuffle)),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                            ),
                          ),
                          const Expanded(
                            child: UpNextQueue(
                              isQueueInSlidePanel: false,
                            ),
                          ),
                        ],
                      ),
                    ),
           */
                  )
                : null,
            body: Obx(
              () => SlidingUpPanel(
                header: !isWideScreen
                    ? InkWell(
                        onTap: playerController.playerPanelController.open,
                        child: const MiniPlayer(),
                      )
                    : const MiniPlayer(),
                onPanelSlide: playerController.panellistener,
                controller: playerController.playerPanelController,
                minHeight: playerController.playerPanelMinHeight.value,
                maxHeight: size.height,
                isDraggable: !isWideScreen,
                onSwipeUp: () {
                  playerController.queuePanelController.open();
                },
                panel: const Player(),
                body: const ScreenNavigation(),
              ),
            ),
            bottomNavigationBar: settingsScreenController.isBottomNavBarEnabled.isTrue
                ? ScrollToHideWidget(
                    isVisible:
                        homeScreenController.isHomeSreenOnTop.isTrue && playerController.isPanelGTHOpened.isFalse,
                    child: const BottomNavBar())
                : null,
          ),
        ),
      ),
    );
  }
}
