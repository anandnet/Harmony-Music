import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ionicons/ionicons.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '/ui/widgets/lyrics_dialog.dart';
import '/ui/widgets/song_info_dialog.dart';
import '/ui/player/player_controller.dart';
import '/ui/widgets/loader.dart';
import '../../widgets/add_to_playlist.dart';
import '../../widgets/sleep_timer_bottom_sheet.dart';
import '../../widgets/song_download_btn.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/mini_player_progress_bar.dart';

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
                                  .valueIndicatorColor,
                              progressBarColor: Theme.of(context)
                                  .sliderTheme
                                  .activeTrackColor,
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
                                  playerController.currentSong.value != null
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
                                child: Marquee(
                                  id: "Mini player artists",
                                  delay: const Duration(milliseconds: 300),
                                  duration: const Duration(seconds: 5),
                                  child: Text(
                                    playerController.currentSong.value != null
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
                                Row(
                                  children: [
                                    IconButton(
                                        iconSize: 20,
                                        onPressed:
                                            playerController.toggleFavourite,
                                        icon: Obx(() => Icon(
                                              playerController
                                                      .isCurrentSongFav.isFalse
                                                  ? Icons
                                                      .favorite_border_rounded
                                                  : Icons.favorite_rounded,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .color,
                                            ))),
                                    IconButton(
                                        iconSize: 20,
                                        onPressed:
                                            playerController.toggleShuffleMode,
                                        icon: Obx(() => Icon(
                                              Ionicons.shuffle,
                                              color: playerController
                                                      .isShuffleModeEnabled
                                                      .value
                                                  ? Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .color
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .color!
                                                      .withOpacity(0.2),
                                            ))),
                                  ],
                                ),
                              if (isWideScreen)
                                SizedBox(
                                    width: 40,
                                    child: InkWell(
                                      onTap: (playerController
                                                  .currentQueue.isEmpty ||
                                              (playerController
                                                      .currentQueue.first.id ==
                                                  playerController
                                                      .currentSong.value?.id))
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
                                      width: 58,
                                      height: 58,
                                      child: Center(
                                          child: _playButton(
                                              context, isWideScreen)))
                                  : SizedBox.square(
                                      dimension: 50,
                                      child: Center(
                                          child: _playButton(
                                              context, isWideScreen))),
                              SizedBox(
                                  width: 40,
                                  child: Obx(() {
                                    final isLastSong =
                                        playerController.currentQueue.isEmpty ||
                                            (playerController
                                                    .isShuffleModeEnabled
                                                    .isFalse &&
                                                (playerController
                                                        .currentQueue.last.id ==
                                                    playerController.currentSong
                                                        .value?.id));
                                    return InkWell(
                                      onTap: isLastSong
                                          ? null
                                          : playerController.next,
                                      child: Icon(
                                        Icons.skip_next_rounded,
                                        color: isLastSong
                                            ? Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .color!
                                                .withOpacity(0.2)
                                            : Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .color,
                                        size: 35,
                                      ),
                                    );
                                  })),
                              if (isWideScreen)
                                Row(
                                  children: [
                                    IconButton(
                                        iconSize: 20,
                                        onPressed:
                                            playerController.toggleLoopMode,
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
                                    IconButton(
                                        iconSize: 20,
                                        onPressed: () {
                                          playerController.showLyrics();
                                          showDialog(
                                                  builder: (context) =>
                                                      const LyricsDialog(),
                                                  context: context)
                                              .whenComplete(() {
                                            playerController
                                                    .isDesktopLyricsDialogOpen =
                                                false;
                                            playerController
                                                .showLyricsflag.value = false;
                                          });
                                          playerController
                                              .isDesktopLyricsDialogOpen = true;
                                        },
                                        icon: Icon(Icons.lyrics_outlined,
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .color)),
                                  ],
                                ),
                              if (isWideScreen)
                                const SizedBox(
                                  width: 20,
                                )
                            ],
                          ),
                        ),
                        if (isWideScreen)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: size.width < 1004 ? 0 : 30.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        right: 20, left: 10),
                                    height: 20,
                                    width: (size.width > 860) ? 220 : 180,
                                    child: Obx(() {
                                      final volume =
                                          playerController.volume.value;
                                      return Row(
                                        children: [
                                          SizedBox(
                                              width: 20,
                                              child: InkWell(
                                                onTap: playerController.mute,
                                                child: Icon(
                                                  volume == 0
                                                      ? Icons.volume_off
                                                      : volume > 0 &&
                                                              volume < 50
                                                          ? Icons.volume_down
                                                          : Icons.volume_up,
                                                  size: 20,
                                                ),
                                              )),
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderTheme.of(context)
                                                  .copyWith(
                                                trackHeight: 2,
                                                thumbShape:
                                                    const RoundSliderThumbShape(
                                                        enabledThumbRadius:
                                                            6.0),
                                                overlayShape:
                                                    const RoundSliderOverlayShape(
                                                        overlayRadius: 10.0),
                                              ),
                                              child: Slider(
                                                value: playerController
                                                        .volume.value /
                                                    100,
                                                onChanged: (value) {
                                                  playerController.setVolume(
                                                      (value * 100).toInt());
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            playerController
                                                .homeScaffoldkey.currentState!
                                                .openEndDrawer();
                                          },
                                          icon: const Icon(Icons.queue_music),
                                        ),
                                        if (size.width > 860)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: IconButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 500),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    10.0)),
                                                  ),
                                                  isScrollControlled: true,
                                                  context: playerController
                                                      .homeScaffoldkey
                                                      .currentState!
                                                      .context,
                                                  barrierColor: Colors
                                                      .transparent
                                                      .withAlpha(100),
                                                  builder: (context) =>
                                                      const SleepTimerBottomSheet(),
                                                );
                                              },
                                              icon: Icon(playerController
                                                      .isSleepTimerActive.isTrue
                                                  ? Icons.timer
                                                  : Icons.timer_outlined),
                                            ),
                                          ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const SongDownloadButton(
                                          calledFromPlayer: true,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            final currentSong = playerController
                                                .currentSong.value;
                                            if (currentSong != null) {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AddToPlaylist(
                                                        [currentSong]),
                                              ).whenComplete(() => Get.delete<
                                                  AddToPlaylistController>());
                                            }
                                          },
                                          icon: const Icon(Icons.playlist_add),
                                        ),
                                        if (size.width > 965)
                                          IconButton(
                                            onPressed: () {
                                              final currentSong =
                                                  playerController
                                                      .currentSong.value;
                                              if (currentSong != null) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      SongInfoDialog(
                                                          song: currentSong,
                                                          isDownloaded: Hive.box(
                                                                  "SongDownloads")
                                                              .containsKey(
                                                                  currentSong
                                                                      .id)),
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.info,
                                                size: 22),
                                          ),
                                      ],
                                    ),
                                  ),
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
