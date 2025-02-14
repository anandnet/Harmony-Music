import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/components/backgroud_image.dart';
import 'package:ionicons/ionicons.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '../../widgets/songinfo_bottom_sheet.dart';
import '../../utils/theme_controller.dart';
import '../player_controller.dart';

class GesturePlayer extends StatelessWidget {
  const GesturePlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    return Stack(
      children: [
        GestureDetector(
          /// Full screen Background image is acting as album art
          child: const BackgroudImage(),
          onHorizontalDragEnd: (DragEndDetails details) {
            if (details.primaryVelocity! < 0) {
              playerController.next();
            } else if (details.primaryVelocity! > 0) {
              playerController.prev();
            }
          },
          onDoubleTap: () {
            playerController.playPause();
          },
          onLongPress: () {
            showModalBottomSheet(
              constraints: const BoxConstraints(maxWidth: 500),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
              ),
              isScrollControlled: true,
              context: playerController.homeScaffoldkey.currentState!.context,
              barrierColor: Colors.transparent.withAlpha(100),
              builder: (context) => SongInfoBottomSheet(
                playerController.currentSong.value!,
                calledFromPlayer: true,
              ),
            ).whenComplete(() => Get.delete<SongInfoController>());
          },
        ),
        IgnorePointer(
          child: Align(
            child: Center(
              child: Obx(
                () => FadeTransition(
                  opacity: playerController.gesturePlayerStateAnimation!,
                  child: playerController.gesturePlayerVisibleState.value == 2
                      ? const SizedBox.shrink()
                      : Icon(
                          playerController.gesturePlayerVisibleState.value == 1
                              ? Icons.play_arrow
                              : Icons.pause,
                          size: 180,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: Get.mediaQuery.padding.bottom != 0
                    ? Get.mediaQuery.padding.bottom + 10
                    : 20,
                left: 20,
                right: 20),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10)),
              constraints: const BoxConstraints(maxWidth: 500),
              height: 142,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() {
                                    return Marquee(
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(seconds: 10),
                                      id: "${playerController.currentSong.value}_title",
                                      child: Text(
                                        playerController.currentSong.value !=
                                                null
                                            ? playerController
                                                .currentSong.value!.title
                                            : "NA",
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .complementaryColor),
                                      ),
                                    );
                                  }),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  GetX<PlayerController>(builder: (controller) {
                                    return Marquee(
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(seconds: 10),
                                      id: "${playerController.currentSong.value}_subtitle",
                                      child: Text(
                                        playerController.currentSong.value !=
                                                null
                                            ? controller
                                                .currentSong.value!.artist!
                                            : "NA",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .complementaryColor,
                                                fontWeight: FontWeight.normal),
                                      ),
                                    );
                                  }),
                                ]),
                          ),
                          SizedBox(
                            width: 75,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                    splashRadius: 10,
                                    iconSize: 20,
                                    visualDensity: const VisualDensity(
                                        horizontal: -4, vertical: -4),
                                    onPressed: playerController.toggleFavourite,
                                    icon: Obx(() => Icon(
                                          playerController
                                                  .isCurrentSongFav.isFalse
                                              ? Icons.favorite_border
                                              : Icons.favorite,
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .color,
                                        ))),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Obx(() {
                                      return IconButton(
                                          splashRadius: 10,
                                          visualDensity: const VisualDensity(
                                              horizontal: -4, vertical: -4),
                                          iconSize: 18,
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
                                          ));
                                    }),
                                    IconButton(
                                      iconSize: 18,
                                      splashRadius: 10,
                                      visualDensity: const VisualDensity(
                                          horizontal: -4, vertical: -4),
                                      onPressed:
                                          playerController.toggleShuffleMode,
                                      icon: Obx(
                                        () => Icon(
                                          Ionicons.shuffle,
                                          color: playerController
                                                  .isShuffleModeEnabled.value
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .color
                                              : Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .color!
                                                  .withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      GetX<PlayerController>(builder: (controller) {
                        return ProgressBar(
                          thumbRadius: 6,
                          baseBarColor:
                              Theme.of(context).sliderTheme.inactiveTrackColor,
                          bufferedBarColor:
                              Theme.of(context).sliderTheme.valueIndicatorColor,
                          progressBarColor:
                              Theme.of(context).sliderTheme.activeTrackColor,
                          thumbColor: Theme.of(context).sliderTheme.thumbColor,
                          timeLabelTextStyle: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .complementaryColor),
                          progress: controller.progressBarStatus.value.current,
                          total: controller.progressBarStatus.value.total,
                          buffered: controller.progressBarStatus.value.buffered,
                          onSeek: controller.seek,
                        );
                      }),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
        // absorb pointer to prevent the next,prev gesture from being triggered when the user tries to switch app
        Align(
          alignment: Alignment.bottomCenter,
          child: AbsorbPointer(
            child: SizedBox(
              height: Get.mediaQuery.padding.bottom + 20,
              child: Container(),
            ),
          ),
        )
      ],
    );
  }
}
