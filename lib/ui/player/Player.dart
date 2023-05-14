import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/settings_screen_controller.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';
import 'package:harmonymusic/ui/widgets/marqwee_widget.dart';

import '../widgets/image_widget.dart';
import '../widgets/sliding_up_panel.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    printINFO("player");
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();
    final ThemeController themeController = Get.find<ThemeController>();
    return Scaffold(
      body: SlidingUpPanel(
          minHeight: 65 + Get.mediaQuery.padding.bottom,
          maxHeight: size.height,
          collapsed: Container(
              color: Theme.of(context).bottomSheetTheme.modalBarrierColor,
              child: Column(
                children: [
                  SizedBox(
                    height: 65,
                    child: Center(
                        child: Icon(
                      color: Theme.of(context).textTheme.titleMedium!.color,
                      Icons.keyboard_arrow_up,
                      size: 40,
                    )),
                  ),
                ],
              )),
          panelBuilder: (ScrollController sc) {
            playerController.scrollController = sc;
            return Container(
                color: Theme.of(context).bottomSheetTheme.backgroundColor,
                child: Obx(() {
                  return ListView.builder(
                    controller: playerController.scrollController,
                    itemCount: playerController.currentQueue.length,
                    padding: EdgeInsets.only(
                        top: 55, bottom: Get.mediaQuery.padding.bottom),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      //print("${playerController.currentSongIndex.value == index} $index");
                      return Material(
                          child: Obx(() => ListTile(
                                onTap: () {
                                  playerController.seekByIndex(index);
                                },
                                contentPadding: const EdgeInsets.only(
                                    top: 0, left: 30, right: 30),
                                tileColor:
                                    playerController.currentSongIndex.value ==
                                            index
                                        ? Theme.of(context)
                                            .colorScheme.secondary
                                        : Theme.of(context)
                                            .bottomSheetTheme
                                            .backgroundColor,
                                leading: SizedBox.square(
                                    dimension: 50,
                                    child: ImageWidget(
                                      song:
                                          playerController.currentQueue[index],
                                    )),
                                title: Text(
                                  playerController.currentQueue[index].title,
                                  maxLines: 1,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Text(
                                  "${playerController.currentQueue[index].artist}",
                                  maxLines: 1,
                                  style: playerController
                                              .currentSongIndex.value ==
                                          index
                                      ? Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .color!
                                                  .withOpacity(0.35))
                                      : Theme.of(context).textTheme.titleSmall,
                                ),
                                trailing:
                                    playerController.currentSongIndex.value ==
                                            index
                                        ? const Icon(
                                            Icons.equalizer,
                                            color: Colors.white,
                                          )
                                        : Text(
                                            playerController.currentQueue[index]
                                                    .extras!['length'] ??
                                                "",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                              )));
                    },
                  );
                }));
          },
          body: Stack(
            children: [
              Obx(
                () => SizedBox.expand(
                  child: playerController.currentSong.value != null
                      ? CachedNetworkImage(
                          memCacheHeight: 200,
                          imageBuilder: (context, imageProvider) {
                            Get.find<SettingsScreenController>()
                                        .themeModetype
                                        .value ==
                                    ThemeType.dynamic
                                ? themeController.setTheme(imageProvider)
                                : null;
                            return Image(
                              image: imageProvider,
                              fit: BoxFit.fitHeight,
                            );
                          },
                          imageUrl: playerController.currentSong.value!.artUri
                              .toString(),
                          cacheKey:
                              "${playerController.currentSong.value!.id}_song",
                        )
                      : Container(),
                ),
              ),

              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.90)),
              ),

              //Player Top content
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 120,
                    ),
                    SizedBox(
                        height: size.width - 60,
                        width: size.width - 60,
                        child:
                            Obx(() => playerController.currentSong.value != null
                                ? ImageWidget(
                                    song: playerController.currentSong.value!,
                                    isLargeImage: true,
                                  )
                                : Container())),
                    Expanded(child: Container()),
                    Obx(() {
                      return MarqueeWidget(
                        child: Text(
                          playerController.currentSong.value != null
                              ? playerController.currentSong.value!.title
                              : "NA",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      );
                    }),
                    const SizedBox(
                      height: 10,
                    ),
                    GetX<PlayerController>(builder: (controller) {
                      return MarqueeWidget(
                        child: Text(
                          playerController.currentSong.value != null
                              ? controller.currentSong.value!.artist!
                              : "NA",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      );
                    }),
                    const SizedBox(
                      height: 20,
                    ),
                    GetX<PlayerController>(builder: (controller) {
                      return ProgressBar(
                        baseBarColor:
                            Theme.of(context).sliderTheme.inactiveTrackColor,
                        bufferedBarColor:
                            Theme.of(context).sliderTheme.activeTrackColor,
                        progressBarColor:
                            Theme.of(context).sliderTheme.valueIndicatorColor,
                        thumbColor: Theme.of(context).sliderTheme.thumbColor,
                        timeLabelTextStyle:
                            Theme.of(context).textTheme.titleMedium,
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
                            onPressed: playerController.toggleFavourite,
                            icon: Obx(() => Icon(
                                  playerController.isCurrentSongFav.isFalse
                                      ? Icons.favorite_border
                                      : Icons.favorite,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .color,
                                ))),
                        _previousButton(playerController, context),
                        CircleAvatar(radius: 35, child: _playButton()),
                        _nextButton(playerController, context),
                        Obx(() {
                          return IconButton(
                              onPressed: playerController.toggleLoopMode,
                              icon: Icon(
                                Icons.all_inclusive,
                                color:
                                    playerController.isLoopModeEnabled.value
                                        ? Colors.green
                                        : Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .color,
                              ));
                        }),
                      ],
                    ),
                    SizedBox(
                      height: 90 + Get.mediaQuery.padding.bottom,
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _playButton() {
    return GetX<PlayerController>(builder: (controller) {
      final buttonState = controller.buttonState.value;
      if (buttonState == PlayButtonState.paused) {
        return IconButton(
          icon: const Icon(Icons.play_arrow_rounded),
          iconSize: 40.0,
          onPressed: controller.play,
        );
      } else if (buttonState == PlayButtonState.playing) {
        return IconButton(
          icon: const Icon(Icons.pause_rounded),
          iconSize: 40.0,
          onPressed: controller.pause,
        );
      } else {
        return IconButton(
          icon: const Icon(Icons.play_arrow_rounded),
          iconSize: 40.0,
          onPressed: () => controller.replay,
        );
      }
    });
  }

  Widget _previousButton(
      PlayerController playerController, BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.skip_previous_rounded,
        color: Theme.of(context).textTheme.titleMedium!.color,
      ),
      iconSize: 30,
      onPressed: playerController.prev,
    );
  }
}

Widget _nextButton(PlayerController playerController, BuildContext context) {
  return IconButton(
    icon: Icon(
      Icons.skip_next_rounded,
      color: Theme.of(context).textTheme.titleMedium!.color,
    ),
    iconSize: 30,
    onPressed: () async {
      await playerController.next();
    },
  );
}
