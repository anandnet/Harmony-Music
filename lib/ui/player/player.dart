import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:harmonymusic/ui/player/components/gesture_player.dart';
import 'package:harmonymusic/ui/player/components/standard_player.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';

import '../../utils/helper.dart';
import '../widgets/snackbar.dart';
import '../widgets/up_next_queue.dart';
import '/ui/player/player_controller.dart';
import '../widgets/sliding_up_panel.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    printINFO("player");
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();
    final settingsScreenController = Get.find<SettingsScreenController>();
    return Scaffold(
        body: Obx(() => SlidingUpPanel(
              boxShadow: const [],
              minHeight: settingsScreenController.playerUi.value == 0
                  ? 65 + Get.mediaQuery.padding.bottom
                  : 0,
              maxHeight: size.height,
              isDraggable: !GetPlatform.isDesktop,
              controller: GetPlatform.isDesktop
                  ? null
                  : playerController.queuePanelController,
              collapsed: InkWell(
                onTap: () {
                  if (GetPlatform.isDesktop) {
                    playerController.homeScaffoldkey.currentState!
                        .openEndDrawer();
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
                            color:
                                Theme.of(context).textTheme.titleMedium!.color,
                            Icons.keyboard_arrow_up_rounded,
                            size: 40,
                          )),
                        ),
                      ],
                    )),
              ),
              panelBuilder:
                  (ScrollController sc, onReorderStart, onReorderEnd) {
                playerController.scrollController = sc;
                return Stack(
                  children: [
                    UpNextQueue(
                      onReorderEnd: onReorderEnd,
                      onReorderStart: onReorderStart,
                    ),
                    Positioned(
                        bottom: 60,
                        right: 15,
                        child: SizedBox(
                            height: 60,
                            width: 60,
                            child: FittedBox(
                                child: FloatingActionButton(
                                    focusElevation: 0,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(14))),
                                    elevation: 0,
                                    onPressed: () {
                                      if (playerController
                                          .isShuffleModeEnabled.isTrue) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar(context,
                                                "queueShufflingDeniedMsg".tr,
                                                size: SanckBarSize.BIG));
                                        return;
                                      }
                                      playerController.shuffleQueue();
                                    },
                                    child: const Icon(Icons.shuffle))))),
                  ],
                );
              },
              body: settingsScreenController.playerUi.value == 0
                  ? const StandardPlayer()
                  : const GesturePlayer(),
            )));
  }
}
