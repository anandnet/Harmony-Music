import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find();
    return Scaffold( 
      body: SlidingUpPanel(
          color: Colors.red,
          minHeight: 70,
          maxHeight: size.height,
          panel: Center(
            child: Container(),
          ),
          
          body: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Column(
              children: [
                const SizedBox(
                  height: 120,
                ),
                SizedBox(
                  height: 290,
                  child: Image.network(
                      "https://lh3.googleusercontent.com/BZBfTByEyZo6l74pbQLGQy-7-FTnYrt5UOpJdrUhdgjpbfMC8f60_ZPRkKiC2JE0RPUpp-cW-hYKOfp_4w=w544-h544-l90-rj"),
                ),
                Expanded(child: Container()),
                const Text(
                  "Tere Liye",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  textAlign: TextAlign.center,
                  "Lata Mangeshkar & Roop Kumar Rathod",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                const SizedBox(
                  height: 20,
                ),
                GetX<PlayerController>(builder: (controller) {
                  return ProgressBar(
                    progress: controller.progressBarStatus.value.current,
                    total: controller.progressBarStatus.value.total,
                    buffered: controller.progressBarStatus.value.buffered,
                    onSeek: controller.seek,
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border)),
                    _previousButton(playerController),
                    CircleAvatar(
                        radius: 35, child: _playButton()),
                    _nextButton(playerController),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.shuffle,
                        )),
                  ],
                ),
                const SizedBox(
                  height: 90,
                )
              ],
            ),
          )),
    );
  }

  Widget _playButton() {
    return GetX<PlayerController>(builder: (controller) {
      final buttonState = controller.buttonState.value;
      if (buttonState == PlayButtonState.loading) {
        // 2
        return const SizedBox(
          //margin: EdgeInsets.all(8.0),
          width: 64.0,
          height: 64.0,
          child: CircularProgressIndicator(),
        );
      } else if (buttonState == PlayButtonState.paused) {
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          iconSize: 40.0,
          onPressed: controller.play,
        );
      } else if (buttonState == PlayButtonState.playing) {
        return IconButton(
          icon: const Icon(Icons.pause),
          iconSize: 40.0,
          onPressed: controller.pause,
        );
      } else {
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          iconSize: 40.0,
          onPressed: () => controller.replay,
        );
      }
    });
  }

  Widget _previousButton(PlayerController playerController) {
        return IconButton(
          icon: const Icon(Icons.skip_previous_rounded, size: 30),
          onPressed: playerController.prev,
        );
      }
  }

  Widget _nextButton(PlayerController playerController) {
    return IconButton(
          icon: const Icon(
            Icons.skip_next,
            size: 30,
          ),
          onPressed: playerController.next,
        );
      }
