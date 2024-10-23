import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/player/components/mini_player.dart';
import 'package:harmonymusic/ui/player/player.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/bottom_nav_bar.dart';
import 'package:harmonymusic/ui/widgets/scroll_to_hide.dart';
import 'package:harmonymusic/ui/widgets/sliding_up_panel.dart';
import 'package:harmonymusic/ui/widgets/up_next_queue.dart';
import 'package:harmonymusic/utils/helper.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static const routeName = '/appHome';

  @override
  Widget build(BuildContext context) {
    printINFO('Home');
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
              await Get.find<AudioHandler>().customAction('saveSession');
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
                                    'upNext'.tr,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  row.children([
                                    InkWell(
                                      onTap: playerController.toggleQueueLoopMode,
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
                                          child: Center(child: Text('queueLoop'.tr)),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.shuffle),
                                    ),
                                  ]),
                                ]),
                              ),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: UpNextQueue(
                            isQueueInSlidePanel: false,
                          ),
                        )
                      ]),
                    ),
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
