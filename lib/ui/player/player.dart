import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/loader.dart';
import '../../utils/helper.dart';
import '/ui/player/player_controller.dart';
import '/ui/screens/settings_screen_controller.dart';
import '/ui/utils/theme_controller.dart';
import '/ui/widgets/marqwee_widget.dart';
import '/ui/widgets/songinfo_bottom_sheet.dart';
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
    final playerArtImageSize = size.width - ((size.height < 750) ? 90 : 60);
    return Scaffold(
      body: SlidingUpPanel(
          minHeight: 65 + Get.mediaQuery.padding.bottom,
          maxHeight: size.height,
          isDraggable: true,
          collapsed: Container(
              color: Theme.of(context).bottomSheetTheme.modalBarrierColor,
              child: Column(
                children: [
                  SizedBox(
                    height: 65,
                    child: Center(
                        child: Icon(
                      color: Theme.of(context).textTheme.titleMedium!.color,
                      Icons.keyboard_arrow_up_rounded,
                      size: 40,
                    )),
                  ),
                ],
              )),
          panelBuilder: (ScrollController sc, onReorderStart, onReorderEnd) {
            playerController.scrollController = sc;
            return Stack(
              children: [
                Container(
                    color: Theme.of(context).bottomSheetTheme.backgroundColor,
                    child: Obx(() {
                      return ReorderableListView.builder(
                        scrollController: playerController.scrollController,
                        onReorder: playerController.onReorder,
                        onReorderStart: onReorderStart,
                        onReorderEnd: onReorderEnd,
                        itemCount: playerController.currentQueue.length,
                        padding: EdgeInsets.only(
                            top: 55, bottom: Get.mediaQuery.padding.bottom),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final homeScaffoldContext =
                              playerController.homeScaffoldkey.currentContext!;
                          //print("${playerController.currentSongIndex.value == index} $index");
                          return Material(
                              key: Key('$index'),
                              child: Obx(() => ListTile(
                                    onTap: () {
                                      playerController.seekByIndex(index);
                                    },
                                    onLongPress: () {
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: playerController
                                            .homeScaffoldkey
                                            .currentState!
                                            .context,
                                        //constraints: BoxConstraints(maxHeight:Get.height),
                                        barrierColor:
                                            Colors.transparent.withAlpha(100),
                                        builder: (context) =>
                                            SongInfoBottomSheet(
                                          playerController.currentQueue[index],
                                          calledFromQueue: true,
                                        ),
                                      ).whenComplete(() =>
                                          Get.delete<SongInfoController>());
                                    },
                                    contentPadding: const EdgeInsets.only(
                                        top: 0, left: 30, right: 25),
                                    tileColor: playerController
                                                .currentSongIndex.value ==
                                            index
                                        ? Theme.of(homeScaffoldContext)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(homeScaffoldContext)
                                            .bottomSheetTheme
                                            .backgroundColor,
                                    leading: ImageWidget(
                                      size: 50,
                                      song:
                                          playerController.currentQueue[index],
                                    ),
                                    title: MarqueeWidget(
                                      child: Text(
                                        playerController
                                            .currentQueue[index].title,
                                        maxLines: 1,
                                        style: Theme.of(homeScaffoldContext)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${playerController.currentQueue[index].artist}",
                                      maxLines: 1,
                                      style: playerController
                                                  .currentSongIndex.value ==
                                              index
                                          ? Theme.of(homeScaffoldContext)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: Theme.of(
                                                          homeScaffoldContext)
                                                      .textTheme
                                                      .titleMedium!
                                                      .color!
                                                      .withOpacity(0.35))
                                          : Theme.of(homeScaffoldContext)
                                              .textTheme
                                              .titleSmall,
                                    ),
                                    trailing: ReorderableDragStartListener(
                                      index: index,
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            right: 5, left: 20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Icon(
                                              Icons.drag_handle_rounded,
                                            ),
                                            playerController.currentSongIndex
                                                        .value ==
                                                    index
                                                ? const Icon(
                                                    Icons.equalizer_rounded,
                                                    color: Colors.white,
                                                  )
                                                : Text(
                                                    playerController
                                                            .currentQueue[index]
                                                            .extras!['length'] ??
                                                        "",
                                                    style: Theme.of(
                                                            homeScaffoldContext)
                                                        .textTheme
                                                        .titleSmall,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )));
                        },
                      );
                    })),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14))),
                                elevation: 0,
                                onPressed: playerController.shuffleQueue,
                                child: const Icon(Icons.shuffle))))),
              ],
            );
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
                    SizedBox(
                      height: size.height < 750 ? 80 : 120,
                    ),
                    Obx(() => playerController.currentSong.value != null
                        ? Stack(
                            children: [
                              InkWell(
                                onLongPress: () {
                                  // printINFO(
                                  //     "${size.width - ((size.height < 750) ? 90 : 60)}");
                                  showModalBottomSheet(
                                    barrierColor:
                                        Colors.transparent.withAlpha(100),
                                    context: context,
                                    builder: (context) => SongInfoBottomSheet(
                                        playerController.currentSong.value!,
                                        calledFromPlayer: true),
                                  ).whenComplete(
                                      () => Get.delete<SongInfoController>());
                                },
                                onTap: () {
                                  playerController.showLyrics();
                                },
                                child: ImageWidget(
                                  size: playerArtImageSize,
                                  song: playerController.currentSong.value!,
                                  isPlayerArtImage: true,
                                ),
                              ),
                              Obx(() => playerController.showLyricsflag.isTrue
                                  ? InkWell(
                                      onTap: () {
                                        playerController.showLyrics();
                                      },
                                      child: Container(
                                        height: playerArtImageSize,
                                        width: playerArtImageSize,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: SingleChildScrollView(
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 0,
                                                    vertical:
                                                        playerArtImageSize /
                                                            3.5),
                                                child: Obx(
                                                  () => playerController
                                                          .isLyricsLoading
                                                          .isFalse
                                                      ? Text(
                                                          playerController
                                                                      .lyrics
                                                                      .value ==
                                                                  "NA"
                                                              ? "Lyrics not available!"
                                                              : playerController
                                                                  .lyrics.value,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .titleMedium!
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white),
                                                        )
                                                      : const Center(
                                                          child:
                                                              LoadingIndicator(),
                                                        ),
                                                ),
                                              ),
                                            ),
                                            IgnorePointer(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.90),
                                                      Colors.transparent,
                                                      Colors.transparent,
                                                      Colors.transparent,
                                                      Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.90)
                                                    ],
                                                    stops: const [
                                                      0,
                                                      0.2,
                                                      0.5,
                                                      0.8,
                                                      1
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()),
                            ],
                          )
                        : Container()),
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
                                      ? Icons.favorite_border_rounded
                                      : Icons.favorite_rounded,
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
                                color: playerController.isLoopModeEnabled.value
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
      } else if (buttonState == PlayButtonState.playing ||
          buttonState == PlayButtonState.loading) {
        return IconButton(
          icon: const Icon(Icons.pause_rounded),
          iconSize: 40.0,
          onPressed: controller.pause,
        );
      } else {
        return IconButton(
          icon: const Icon(Icons.play_arrow_rounded),
          iconSize: 40.0,
          onPressed: () {},
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
  return Obx(() {
    final isLastSong = playerController.currentQueue.isEmpty ||
        (playerController.currentQueue.last.id ==
            playerController.currentSong.value!.id);
    return IconButton(
        icon: Icon(
          Icons.skip_next_rounded,
          color: Theme.of(context).textTheme.titleMedium!.color,
        ),
        iconSize: 30,
        onPressed: isLastSong ? null : playerController.next);
  });
}
