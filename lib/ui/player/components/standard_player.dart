import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screens/Settings/settings_screen_controller.dart';
import '../../utils/theme_controller.dart';
import '../player_controller.dart';
import 'albumart_lyrics.dart';
import 'lyrics_switch.dart';
import 'player_control.dart';

class StandardPlayer extends StatelessWidget {
  const StandardPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();
    final ThemeController themeController = Get.find<ThemeController>();
    double playerArtImageSize =
        size.width - 60; //((size.height < 750) ? 90 : 60);
    //playerArtImageSize = playerArtImageSize > 350 ? 350 : playerArtImageSize;
    final spaceAvailableForArtImage =
        size.height - (70 + Get.mediaQuery.padding.bottom + 330);
    playerArtImageSize = playerArtImageSize > spaceAvailableForArtImage
        ? spaceAvailableForArtImage
        : playerArtImageSize;
    return Stack(
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
                              () => themeController.setTheme(imageProvider,
                                  playerController.currentSong.value!.id))
                          : null;
                      return Image(
                        image: imageProvider,
                        fit: BoxFit.fitHeight,
                      );
                    },
                    imageUrl:
                        playerController.currentSong.value!.artUri.toString(),
                    cacheKey: "${playerController.currentSong.value!.id}_song",
                  )
                : Container(),
          ),
        ),

        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Stack(
            children: [
              // opacity effect on background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.85),
                  ),
                ),
              ),
              // hide queue header
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 65 + Get.mediaQuery.padding.bottom + 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.4),
                        Theme.of(context).primaryColor.withOpacity(0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0, 0.5, 0.8, 1],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        //Player Top content
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: (context.isLandscape)
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
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                        child: AlbumArtNLyrics(
                            playerArtImageSize: playerArtImageSize)),
                    Expanded(child: Container()),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: 80 + Get.mediaQuery.padding.bottom),
                      child: Container(
                          constraints: const BoxConstraints(maxWidth: 500),
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
    );
  }
}
