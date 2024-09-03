import 'dart:io';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:harmonymusic/ui/player/components/albumart_lyrics.dart';
import 'package:harmonymusic/ui/player/components/lyrics_switch.dart';
import 'package:harmonymusic/ui/player/components/player_control.dart';

import '../../utils/helper.dart';
import '../widgets/up_next_queue.dart';
import '/ui/player/player_controller.dart';
import '../screens/Settings/settings_screen_controller.dart';
import '/ui/utils/theme_controller.dart';
import '../widgets/sliding_up_panel.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    printINFO("player");
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();
    final ThemeController themeController = Get.find<ThemeController>();
    double playerArtImageSize = size.width - ((size.height < 750) ? 90 : 60);
    //playerArtImageSize = playerArtImageSize > 350 ? 350 : playerArtImageSize;
    final spaceAvailableForArtImage =
        size.height - (90 + Get.mediaQuery.padding.bottom + 330);
    playerArtImageSize = playerArtImageSize > spaceAvailableForArtImage
        ? spaceAvailableForArtImage
        : playerArtImageSize;
    return Scaffold(
      body: SlidingUpPanel(
          minHeight: 65 + Get.mediaQuery.padding.bottom,
          maxHeight: size.height,
          isDraggable: !GetPlatform.isDesktop,
          collapsed: InkWell(
            onTap: () {
              if (GetPlatform.isDesktop) {
                playerController.homeScaffoldkey.currentState!.openEndDrawer();
              }
            },
            child: Container(
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
          ),
          panelBuilder: (ScrollController sc, onReorderStart, onReorderEnd) {
            playerController.scrollController = sc;
            return Stack(
              children: [
                UpNextQueue(
                  onReorderEnd: onReorderEnd,
                  onReorderStart: onReorderStart,
                ),
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
                          errorWidget: (context, url, error) {
                            final imgFile = File(
                                "${Get.find<SettingsScreenController>().supportDirPath}/thumbnails/${playerController.currentSong.value!.id}.png");
                            if (imgFile.existsSync()) {
                              themeController.setTheme(FileImage(imgFile),
                                  playerController.currentSong.value!.id);
                              return Image.file(imgFile, cacheHeight: 200);
                            }
                            return const SizedBox.shrink();
                          },
                          memCacheHeight: 200,
                          imageBuilder: (context, imageProvider) {
                            Get.find<SettingsScreenController>()
                                        .themeModetype
                                        .value ==
                                    ThemeType.dynamic
                                ? Future.delayed(
                                    const Duration(milliseconds: 250),
                                    () => themeController.setTheme(
                                        imageProvider,
                                        playerController.currentSong.value!.id))
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
                child: (GetPlatform.isMobile && context.isLandscape)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: size.width * .45,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 90.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Center(
                                  child: AlbumArtNLyrics(
                                    playerArtImageSize: size.width * .29,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              width: size.width * .48,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10.0,
                                    right: 10,
                                    bottom: Get.mediaQuery.padding.bottom),
                                child: const PlayerControlWidget(),
                              ))
                          //SizedBox()
                        ],
                      )
                    : Column(
                        children: [
                          Obx(
                            () => playerController.showLyricsflag.value
                                ? SizedBox(
                                    height: size.height < 750 ? 30 : 70,
                                  )
                                : SizedBox(
                                    height: size.height < 750 ? 80 : 120,
                                  ),
                          ),
                          const LyricsSwitch(),
                          AlbumArtNLyrics(
                              playerArtImageSize: playerArtImageSize),
                          Expanded(child: Container()),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: 90 + Get.mediaQuery.padding.bottom),
                            child: Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 500),
                                child: const PlayerControlWidget()),
                          )
                        ],
                      ),
              ),
              if (GetPlatform.isDesktop)
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0, left: 30),
                      child: IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 28,
                        ),
                        onPressed: playerController.playerPanelController.close,
                      ),
                    ))
            ],
          )),
    );
  }
}
