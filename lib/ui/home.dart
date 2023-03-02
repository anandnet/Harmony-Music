import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/Player.dart';
import 'package:harmonymusic/ui/screens/home_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'player/player_controller.dart';
import 'screens/home_screen_controller.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.put(PlayerController());
    final HomeScreenController homeScreenController =
        Get.put(HomeScreenController());
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: Obx(() => SlidingUpPanel(
            header: Obx(() {
              return Visibility(
                visible: playerController.isPlayerpanelTopVisible.value,
                child: Opacity(
                  opacity: playerController.playerPaneOpacity.value,
                  child: Container(
                    height: 75,
                    width: size.width,
                    color: Colors.amber,
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            height: 3,
                            color: Colors.cyan,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 50,
                                  //width: 40,
                                  child: CachedNetworkImage(
                                    imageUrl: playerController
                                            .playlistSongsDetails.isNotEmpty
                                        ? playerController
                                            .currentSong.value!.thumbnail
                                            .sizewith(50)
                                        : "https://lh3.googleusercontent.com/BZBfTByEyZo6l74pbQLGQy-7-FTnYrt5UOpJdrUhdgjpbfMC8f60_ZPRkKiC2JE0RPUpp-cW-hYKOfp_4w=w544-h544-l90-rj",
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        child: Text(
                                          playerController.playlistSongsDetails
                                                  .isNotEmpty
                                              ? playerController
                                                  .currentSong.value!.title
                                              : "",
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                        child: Text(
                                          playerController.playlistSongsDetails
                                                  .isNotEmpty
                                              ? playerController.currentSong
                                                  .value!.artist[0]['name']
                                              : "",
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 45, child: _playButton()),
                                    SizedBox(
                                        width: 40,
                                        child: InkWell(
                                          onTap: playerController.next,
                                          child: const Icon(
                                            Icons.skip_next_rounded,
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
            body: const HomeScreen())));
  }

  Widget _playButton() {
    return GetX<PlayerController>(builder: (controller) {
      final buttonState = controller.buttonState.value;
      if (buttonState == PlayButtonState.paused) {
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          iconSize: 35.0,
          onPressed: controller.play,
        );
      } else if (buttonState == PlayButtonState.playing) {
        return IconButton(
          icon: const Icon(Icons.pause),
          iconSize: 35.0,
          onPressed: controller.pause,
        );
      } else {
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          iconSize: 35.0,
          onPressed: () => controller.replay,
        );
      }
    });
  }
}
