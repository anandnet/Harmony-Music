import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/widgets/loader.dart';
import 'package:harmonymusic/ui/widgets/marqwee_widget.dart';

import '../widgets/song_download_btn.dart';
import '../widgets/image_widget.dart';
import '../widgets/mini_player_progress_bar.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 800;
    return Obx(() {
      return Visibility(
        visible: playerController.isPlayerpanelTopVisible.value,
        child: Opacity(
          opacity: playerController.playerPaneOpacity.value,
          child: Container(
            height: playerController.playerPanelMinHeight.value,
            width: size.width,
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            child: Center(
              child: Column(
                children: [
                  !isWideScreen
                      ? GetX<PlayerController>(
                          builder: (controller) => Container(
                              height: 3,
                              color: Theme.of(context)
                                  .progressIndicatorTheme
                                  .color,
                              child: MiniPlayerProgressBar(
                                  progressBarStatus:
                                      controller.progressBarStatus.value,
                                  progressBarColor: Theme.of(context)
                                          .progressIndicatorTheme
                                          .linearTrackColor ??
                                      Colors.white)),
                        )
                      : GetX<PlayerController>(builder: (controller) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, top: 8, right: 15, bottom: 0),
                            child: ProgressBar(
                              timeLabelLocation: TimeLabelLocation.sides,
                              thumbRadius: 7,
                              barHeight: 4,
                              thumbGlowRadius: 15,
                              baseBarColor: Theme.of(context)
                                  .sliderTheme
                                  .inactiveTrackColor,
                              bufferedBarColor: Theme.of(context)
                                  .sliderTheme
                                  .activeTrackColor,
                              progressBarColor: Theme.of(context)
                                  .sliderTheme
                                  .valueIndicatorColor,
                              thumbColor:
                                  Theme.of(context).sliderTheme.thumbColor,
                              timeLabelTextStyle:
                                  Theme.of(context).textTheme.titleMedium,
                              progress:
                                  controller.progressBarStatus.value.current,
                              total: controller.progressBarStatus.value.total,
                              buffered:
                                  controller.progressBarStatus.value.buffered,
                              onSeek: controller.seek,
                            ),
                          );
                        }),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 17.0, vertical: 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            playerController.currentSong.value != null
                                ? ImageWidget(
                                    size: 50,
                                    song: playerController.currentSong.value!,
                                  )
                                : const SizedBox(
                                    height: 50,
                                    width: 50,
                                  ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                                child: Text(
                                  playerController.currentQueue.isNotEmpty
                                      ? playerController
                                          .currentSong.value!.title
                                      : "",
                                  maxLines: 1,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                                child: MarqueeWidget(
                                  child: Text(
                                    playerController.currentQueue.isNotEmpty
                                        ? playerController
                                            .currentSong.value!.artist!
                                        : "",
                                    maxLines: 1,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //player control
                        SizedBox(
                          width: isWideScreen ? 450 : 90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (isWideScreen)
                                IconButton(
                                    iconSize: 20,
                                    onPressed: playerController.toggleFavourite,
                                    icon: Obx(() => Icon(
                                          playerController
                                                  .isCurrentSongFav.isFalse
                                              ? Icons.favorite_border_rounded
                                              : Icons.favorite_rounded,
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .color,
                                        ))),
                              if (isWideScreen)
                                SizedBox(
                                    width: 40,
                                    child: InkWell(
                                      onTap: (playerController
                                                  .currentQueue.isEmpty ||
                                              (playerController
                                                      .currentQueue.first.id ==
                                                  playerController
                                                      .currentSong.value!.id))
                                          ? null
                                          : playerController.prev,
                                      child: Icon(
                                        Icons.skip_previous_rounded,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .color,
                                        size: 35,
                                      ),
                                    )),
                              isWideScreen
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: 60,
                                      height: 60,
                                      child: Center(
                                          child: _playButton(
                                              context, isWideScreen)))
                                  : SizedBox.square(
                                      dimension:50,
                                      child: Center(
                                          child: _playButton(
                                              context, isWideScreen))),
                              SizedBox(
                                  width: 40,
                                  child: InkWell(
                                    onTap: (playerController
                                                .currentQueue.isEmpty ||
                                            (playerController
                                                    .currentQueue.last.id ==
                                                playerController
                                                    .currentSong.value!.id))
                                        ? null
                                        : playerController.next,
                                    child: Icon(
                                      Icons.skip_next_rounded,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .color,
                                      size: 35,
                                    ),
                                  )),
                              if (isWideScreen)
                                IconButton(
                                    iconSize: 20,
                                    onPressed: playerController.toggleLoopMode,
                                    icon: Icon(
                                      Icons.all_inclusive,
                                      color: playerController
                                              .isLoopModeEnabled.value
                                          ? Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .color
                                          : Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .color!
                                              .withOpacity(0.2),
                                    )),
                              if (isWideScreen)
                                const SizedBox(
                                  width: 40,
                                )
                            ],
                          ),
                        ),
                        if (isWideScreen)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 40.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const SongDownloadButton(),
                                  const SizedBox(width: 10,),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.queue_music),
                                  )
                                ],
                              ),
                            ),
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
    });
  }

  Widget _playButton(BuildContext context, bool isWideScreen) {
    return GetX<PlayerController>(builder: (controller) {
      final buttonState = controller.buttonState.value;
      if (buttonState == PlayButtonState.loading) {
        return IconButton(
          icon: const LoadingIndicator(
            dimension: 20,
          ),
          onPressed: () {},
        );
      }

      if (buttonState == PlayButtonState.paused) {
        return IconButton(
          icon: Icon(
            Icons.play_arrow_rounded,
            color: Theme.of(context).textTheme.titleMedium!.color,
          ),
          iconSize: isWideScreen ? 43.0 : 35.0,
          onPressed: controller.play,
        );
      } else if (buttonState == PlayButtonState.playing ||
          buttonState == PlayButtonState.loading) {
        return IconButton(
          icon: Icon(
            Icons.pause_rounded,
            color: Theme.of(context).textTheme.titleMedium!.color,
          ),
          iconSize: isWideScreen ? 43.0 : 35.0,
          onPressed: controller.pause,
        );
      } else {
        return IconButton(
          icon: Icon(
            Icons.play_arrow_rounded,
            color: Theme.of(context).textTheme.titleMedium!.color,
          ),
          iconSize: 35.0,
          onPressed: () {},
        );
      }
    });
  }
}
