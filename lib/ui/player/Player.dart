import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();
    return Scaffold(
      body: SlidingUpPanel(
          header: Container(
            height: 80,
            color: Colors.blueGrey,
          ),
          footer: Container(
            height: 80,
            color: Colors.amberAccent,
          ),
          padding: const EdgeInsets.only(top: 80, bottom: 80),
          //color: Colors.red,
          minHeight: 70,
          maxHeight: size.height,
          panel: Center(
            child: Obx(
              () {
                return ListView.builder(
                    itemCount: playerController.playlistSongsDetails.length,
                    padding: const EdgeInsets.only(top: 40),
                    itemBuilder: (context, item) {
                      print("${playerController.currentSongIndex.value == item} $item");
                      return Material(
                          child: Obx(() => ListTile(
                                tileColor: playerController.currentSongIndex.value == item
                                    ? Colors.blueAccent
                                    : Colors.white,
                                leading: SizedBox(
                                    width: 50,
                                    child: CachedNetworkImage(
                                        imageUrl: playerController
                                            .playlistSongsDetails[item].thumbnail
                                            .sizewith(40))),
                                title: Text(
                                  playerController.playlistSongsDetails[item].title,
                                ),
                                subtitle: Text(
                                    "${playerController.playlistSongsDetails[item].artist[0]["name"]}"),
                              )));
                    },
                  );
              }
            )
            
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
                  child: Obx( () =>CachedNetworkImage(
                      imageUrl: playerController.currentQueue
                      . isNotEmpty
                          ? playerController.currentSong.value!.thumbnail.sizewith(300)
                          : "https://lh3.googleusercontent.com/BZBfTByEyZo6l74pbQLGQy-7-FTnYrt5UOpJdrUhdgjpbfMC8f60_ZPRkKiC2JE0RPUpp-cW-hYKOfp_4w=w544-h544-l90-rj",
                      fit: BoxFit.fitHeight,
                    ))
      
                ),
                Expanded(child: Container()),
                GetX<PlayerController>(builder: (controller) {
                  return Text(
                    controller.currentQueue.isNotEmpty
                        ? controller.currentSong.value!.title
                        : "NA",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  );
                }),
                const SizedBox(
                  height: 10,
                ),
                GetX<PlayerController>(builder: (controller) {
                  return Text(
                    controller.currentQueue.isNotEmpty
                        ? controller.currentSong.value?.artist[0]["name"]
                        : "NA",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  );
                }),
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
                    CircleAvatar(radius: 35, child: _playButton()),
                    _nextButton(playerController),
                    Obx(
                      () {
                        return IconButton(
                            onPressed: playerController.toggleShuffleMode,
                            icon:  Icon(
                              Icons.shuffle,color: playerController.isShuffleModeEnabled.value ? Colors.green:Colors.black,
                            ));
                      }
                    ),
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
      if (buttonState == PlayButtonState.paused) {
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
