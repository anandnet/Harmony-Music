import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/player/Player.dart';
import 'package:harmonymusic/ui/screens/home_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'player/player_controller.dart';
import 'screens/home_screen_controller.dart';
import 'widgets/image_widget.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  static const routeName = '/appHome';
  @override
  Widget build(BuildContext context) {
    print("Home");
    var safePadding = MediaQuery.of(context).padding.bottom;
    final PlayerController playerController = Get.find<PlayerController>();
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (playerController.playerPanelController.isPanelOpen) {
          playerController.playerPanelController.close();
          return false;
        } else {
          if (Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.canPop()) {
            Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
            return false;
          }
          return true;
        }
      },
      child: Scaffold(
          body: Obx(() => SlidingUpPanel(
              header: Obx(() {
                return Visibility(
                  visible: playerController.isPlayerpanelTopVisible.value,
                  child: Opacity(
                    opacity: playerController.playerPaneOpacity.value,
                    child: Container(
                      height: 75 + safePadding,
                      width: size.width,
                      color: Theme.of(context).bottomSheetTheme.backgroundColor,
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              height: 3,
                              color: Colors.cyan,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 17.0, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox.square(
                                    dimension: 50,
                                    //width: 40,
                                    child: playerController.currentSong.value !=
                                            null
                                        ? ImageWidget(
                                            song: playerController
                                                .currentSong.value!,
                                          )
                                        : const SizedBox(
                                            height: 50,
                                            width: 50,
                                          ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          child: Text(
                                            playerController
                                                    .currentQueue
                                                    .isNotEmpty
                                                ? playerController
                                                    .currentSong.value!.title
                                                : "",
                                            maxLines: 1,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                          child: Text(
                                            playerController
                                                    .currentQueue
                                                    .isNotEmpty
                                                ? playerController.currentSong
                                                    .value!.artist[0]['name']
                                                : "",
                                            maxLines: 1,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: 45,
                                          child: _playButton(context)),
                                      SizedBox(
                                          width: 40,
                                          child: InkWell(
                                            onTap: playerController.next,
                                            child: Icon(
                                              Icons.skip_next_rounded,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .color,
                                              size: 35,
                                            ),
                                          ))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              onPanelSlide: playerController.panellistener,
              controller: playerController.playerPanelController,
              minHeight: playerController.playerPanelMinHeight.value,
              maxHeight: size.height,
              panel: const Player(),
              body: const ScreenNavigation()))),
    );
  }

  Widget _playButton(BuildContext context) {
    return GetX<PlayerController>(builder: (controller) {
      final buttonState = controller.buttonState.value;
      if (buttonState == PlayButtonState.paused) {
        return IconButton(
          icon: Icon(
            Icons.play_arrow_rounded,
            color: Theme.of(context).textTheme.titleMedium!.color,
          ),
          iconSize: 35.0,
          onPressed: controller.play,
        );
      } else if (buttonState == PlayButtonState.playing) {
        return IconButton(
          icon: Icon(
            Icons.pause_rounded,
            color: Theme.of(context).textTheme.titleMedium!.color,
          ),
          iconSize: 35.0,
          onPressed: controller.pause,
        );
      } else {
        return IconButton(
          icon: Icon(
            Icons.play_arrow_rounded,
            color: Theme.of(context).textTheme.titleMedium!.color,
          ),
          iconSize: 35.0,
          onPressed: () => controller.replay,
        );
      }
    });
  }
}
