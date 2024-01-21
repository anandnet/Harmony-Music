import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';

import '../utils/helper.dart';
import '../ui/navigator.dart';
import '../ui/player/player.dart';
import 'player/mini_player.dart';
import 'player/player_controller.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/scroll_to_hide.dart';
import 'widgets/sliding_up_panel.dart';

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
    if (!playerController.initFlagForPlayer) {
      if (isWideScreen) {
        playerController.playerPanelMinHeight.value =
            105 + Get.mediaQuery.padding.bottom;
      } else {
        playerController.playerPanelMinHeight.value =
            75 + Get.mediaQuery.padding.bottom;
      }
    }
    return WillPopScope(
        onWillPop: () async {
          if (playerController.playerPanelController.isPanelOpen) {
            playerController.playerPanelController.close();
            return false;
          } else {
            if (Get.nestedKey(ScreenNavigationSetup.id)!
                .currentState!
                .canPop()) {
              Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
              return false;
            }
            return true;
          }
        },
        child: Obx(
          () => Scaffold(
              bottomNavigationBar: settingsScreenController
                      .isBottomNavBarEnabled.isTrue
                  ? ScrollToHideWidget(
                      isVisible: homeScreenController.isHomeSreenOnTop.isTrue &&
                          playerController.isPanelGTHOpened.isFalse,
                      child: const BottomNavBar())
                  : null,
              key: playerController.homeScaffoldkey,
              body: Obx(() => SlidingUpPanel(
                    onPanelSlide: playerController.panellistener,
                    controller: playerController.playerPanelController,
                    minHeight: playerController.playerPanelMinHeight.value,
                    maxHeight: size.height,
                    isDraggable: !isWideScreen,
                    panel: const Player(),
                    body: const ScreenNavigation(),
                    header: !isWideScreen
                        ? InkWell(
                            onTap: playerController.playerPanelController.open,
                            child: const MiniPlayer(),
                          )
                        : const MiniPlayer(),
                  ))),
        ));
  }
}
