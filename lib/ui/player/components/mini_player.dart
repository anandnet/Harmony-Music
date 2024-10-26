import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/widgets/add_to_playlist.dart';
import 'package:harmonymusic/ui/widgets/image_widget.dart';
import 'package:harmonymusic/ui/widgets/loader.dart';
import 'package:harmonymusic/ui/widgets/lyrics_dialog.dart';
import 'package:harmonymusic/ui/widgets/mini_player_progress_bar.dart';
import 'package:harmonymusic/ui/widgets/sleep_timer_bottom_sheet.dart';
import 'package:harmonymusic/ui/widgets/song_download_btn.dart';
import 'package:harmonymusic/ui/widgets/song_info_dialog.dart';
import 'package:hive/hive.dart';
import 'package:ionicons/ionicons.dart';
import 'package:widget_marquee/widget_marquee.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 800;
    return Obx(() {
      return Visibility(
        visible: playerController.isPlayerPanelTopVisible.value,
        child: Opacity(
          opacity: playerController.playerPaneOpacity.value,
          child: Container(
            height: playerController.playerPanelMinHeight.value,
            width: size.width,
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            child: Center(
              child: column.children([
                if (!isWideScreen)
                  GetX<PlayerController>(
                    builder: (controller) {
                      return container.h6
                          .color(Theme.of(context).progressIndicatorTheme.color)
                          .child(MiniPlayerProgressBar(
                            progressBarStatus: controller.progressBarStatus.value,
                            progressBarColor: Theme.of(context).progressIndicatorTheme.linearTrackColor ?? Colors.white,
                          ));
                    },
                  )
                else
                  GetX<PlayerController>(builder: (controller) {
                    return padding.pl30.pt16.pr30.child(
                      ProgressBar(
                        timeLabelLocation: TimeLabelLocation.sides,
                        thumbRadius: 7,
                        barHeight: 4,
                        thumbGlowRadius: 15,
                        baseBarColor: Theme.of(context).sliderTheme.inactiveTrackColor,
                        bufferedBarColor: Theme.of(context).sliderTheme.valueIndicatorColor,
                        progressBarColor: Theme.of(context).sliderTheme.activeTrackColor,
                        thumbColor: Theme.of(context).sliderTheme.thumbColor,
                        timeLabelTextStyle: Theme.of(context).textTheme.titleMedium,
                        progress: controller.progressBarStatus.value.current,
                        total: controller.progressBarStatus.value.total,
                        buffered: controller.progressBarStatus.value.buffered,
                        onSeek: controller.seek,
                      ),
                    );
                  }),
                padding.ph38.pv16.child(
                  row.spaceBetween.children([
                    row.children([
                      if (playerController.currentSong.value != null)
                        ImageWidget(
                          size: 50,
                          song: playerController.currentSong.value!,
                        )
                      else
                        const SizedBox(
                          height: 50,
                          width: 50,
                        ),
                    ]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onHorizontalDragEnd: (DragEndDetails details) {
                          if (details.primaryVelocity! < 0) {
                            playerController.next();
                          } else if (details.primaryVelocity! > 0) {
                            playerController.prev();
                          }
                        },
                        child: ColoredBox(
                          color: Colors.transparent,
                          child: column.center.crossStart.children([
                            sizedBox.h44.child(
                              Text(
                                playerController.currentSong.value != null
                                    ? playerController.currentSong.value!.title
                                    : '',
                                maxLines: 1,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            sizedBox.h44.child(
                              Marquee(
                                id: '${playerController.currentSong.value}_mini',
                                delay: const Duration(milliseconds: 300),
                                duration: const Duration(seconds: 5),
                                child: Text(
                                  playerController.currentSong.value != null
                                      ? playerController.currentSong.value!.artist!
                                      : '',
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    //player control

                    SizedBox(
                      width: isWideScreen ? 450 : 150,
                      child: row.spaceEvenly.children([
                        if (isWideScreen)
                          row.children([
                            IconButton(
                                iconSize: 20,
                                onPressed: playerController.toggleFavourite,
                                icon: Obx(() => Icon(
                                      playerController.isCurrentSongFav.isFalse
                                          ? Icons.favorite_border_rounded
                                          : Icons.favorite_rounded,
                                      color: Theme.of(context).textTheme.titleMedium!.color,
                                    ))),
                            IconButton(
                                iconSize: 20,
                                onPressed: playerController.toggleShuffleMode,
                                icon: Obx(() => Icon(
                                      Ionicons.shuffle,
                                      color: playerController.isShuffleModeEnabled.value
                                          ? Theme.of(context).textTheme.titleLarge!.color
                                          : Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.2),
                                    ))),
                          ]),
                        if (isWideScreen)
                          sizedBox.w80.child(InkWell(
                            onTap: (playerController.currentQueue.isEmpty ||
                                    (playerController.currentQueue.first.id == playerController.currentSong.value?.id))
                                ? null
                                : playerController.prev,
                            child: Icons.skip_previous_rounded.icon.s74
                                .color(Theme.of(context).textTheme.titleMedium!.color)
                                .mk,
                          )),
                        if (isWideScreen)
                          container.s130.rounded22
                              .color(
                                Theme.of(context).colorScheme.secondary,
                              )
                              .child(Center(
                                child: _playButton(context, isWideScreen),
                              ))
                        else
                          SizedBox.square(
                              dimension: 50,
                              child: Center(
                                child: _playButton(context, isWideScreen),
                              )),
                        sizedBox.w80.child(
                          Obx(() {
                            final isLastSong = playerController.currentQueue.isEmpty ||
                                (!(playerController.isShuffleModeEnabled.isTrue ||
                                        playerController.isQueueLoopModeEnabled.isTrue) &&
                                    (playerController.currentQueue.last.id == playerController.currentSong.value?.id));
                            return InkWell(
                                onTap: isLastSong ? null : playerController.next,
                                child: Icons.skip_next_rounded.icon.s74
                                    .color(
                                      isLastSong
                                          ? Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.2)
                                          : Theme.of(context).textTheme.titleMedium!.color,
                                    )
                                    .mk);
                          }),
                        ),
                        if (isWideScreen)
                          row.children([
                            IconButton(
                                onPressed: playerController.toggleLoopMode,
                                icon: Icons.all_inclusive.icon.s48
                                    .color(playerController.isLoopModeEnabled.value
                                        ? Theme.of(context).textTheme.titleLarge!.color
                                        : Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.2))
                                    .mk),
                            IconButton(
                              onPressed: () {
                                playerController.showLyrics();
                                showDialog(
                                  context: context,
                                  builder: (context) => const LyricsDialog(),
                                ).whenComplete(() {
                                  playerController.isDesktopLyricsDialogOpen = false;
                                  playerController.showLyricsflag.value = false;
                                });
                                playerController.isDesktopLyricsDialogOpen = true;
                              },
                              icon: Icons.lyrics_outlined.icon.s48
                                  .color(Theme.of(context).textTheme.titleLarge!.color)
                                  .mk,
                            )
                          ]),
                        if (isWideScreen) const SizedBox(width: 20)
                      ]),
                    ),
                    if (isWideScreen)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: size.width < 1004 ? 0 : 30.0),
                          child: column.crossEnd.center.children([
                            Container(
                              padding: const EdgeInsets.only(right: 20, left: 10),
                              height: 20,
                              width: (size.width > 860) ? 220 : 180,
                              child: Obx(() {
                                final volume = playerController.volume.value;
                                return row.children([
                                  sizedBox.w40.child(
                                    InkWell(
                                      onTap: playerController.mute,
                                      child: Icon(
                                        volume == 0
                                            ? Icons.volume_off
                                            : volume > 0 && volume < 50
                                                ? Icons.volume_down
                                                : Icons.volume_up,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 2,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                      ),
                                      child: Slider(
                                        value: playerController.volume.value / 100,
                                        onChanged: (value) {
                                          playerController.setVolume((value * 100).toInt());
                                        },
                                      ),
                                    ),
                                  ),
                                ]);
                              }),
                            ),
                            sizedBox.h80.child(
                              row.end.children([
                                IconButton(
                                  onPressed: () {
                                    playerController.homeScaffoldKey.currentState!.openEndDrawer();
                                  },
                                  icon: Icons.queue_music.icon.mk,
                                ),
                                if (size.width > 860)
                                  padding.pl20.child(
                                    IconButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          constraints: const BoxConstraints(maxWidth: 500),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                          ),
                                          isScrollControlled: true,
                                          context: playerController.homeScaffoldKey.currentState!.context,
                                          barrierColor: Colors.transparent.withAlpha(100),
                                          builder: (context) => const SleepTimerBottomSheet(),
                                        );
                                      },
                                      icon: Icon(playerController.isSleepTimerActive.isTrue
                                          ? Icons.timer
                                          : Icons.timer_outlined),
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                const SongDownloadButton(calledFromPlayer: true),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    final currentSong = playerController.currentSong.value;
                                    if (currentSong != null) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AddToPlaylist([currentSong]),
                                      ).whenComplete(() => Get.delete<AddToPlaylistController>());
                                    }
                                  },
                                  icon: Icons.playlist_add.icon.mk,
                                ),
                                if (size.width > 965)
                                  IconButton(
                                    onPressed: () {
                                      final currentSong = playerController.currentSong.value;
                                      if (currentSong != null) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => SongInfoDialog(
                                              song: currentSong,
                                              isDownloaded: Hive.box('SongDownloads').containsKey(currentSong.id)),
                                        );
                                      }
                                    },
                                    icon: Icons.info.icon.s48.mk,
                                  ),
                              ]),
                            )
                          ]),
                        ),
                      )
                  ]),
                ),
              ]),
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
      } else if (buttonState == PlayButtonState.playing || buttonState == PlayButtonState.loading) {
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
          iconSize: 35,
          onPressed: () {},
        );
      }
    });
  }
}
