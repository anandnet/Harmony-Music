import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screens/Settings/settings_screen_controller.dart';
import '../../utils/theme_controller.dart';
import '../player_controller.dart';

class BackgroudImage extends StatelessWidget {
  const BackgroudImage({super.key, this.cacheHeight});

  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    return GetX<PlayerController>(
      builder: (playerController) => SizedBox.expand(
        /// if song is null then return empty container
        child: playerController.currentSong.value != null

            /// if song is local then return image from local file
            ? (playerController.currentSong.value!.extras!['url'] ?? '')
                    .contains('file')
                ? Builder(builder: (context) {
                    final imgFile = File(
                        "${Get.find<SettingsScreenController>().supportDirPath}/thumbnails/${playerController.currentSong.value!.id}.png");
                    return FutureBuilder(
                      future: imgFile.exists(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            snapshot.data == true) {

                          /// if theme mode is dynamic then set the theme with image
                          if (Get.find<SettingsScreenController>()
                                  .themeModetype
                                  .value ==
                              ThemeType.dynamic) {
                            Get.find<ThemeController>().setTheme(
                                FileImage(imgFile),
                                playerController.currentSong.value!.id);
                          }

                          return Image.file(
                            imgFile,
                            cacheHeight: cacheHeight,
                            fit: BoxFit.cover,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  })

                /// else return image from network
                : CachedNetworkImage(
                    memCacheHeight: cacheHeight,
                    imageBuilder: (context, imageProvider) {
                      Get.find<SettingsScreenController>()
                                  .themeModetype
                                  .value ==
                              ThemeType.dynamic
                          ? Future.delayed(
                              const Duration(milliseconds: 50),
                              () => Get.find<ThemeController>().setTheme(
                                  imageProvider,
                                  playerController.currentSong.value!.id))
                          : null;
                      return Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      );
                    },
                    imageUrl:
                        playerController.currentSong.value!.artUri.toString(),
                    cacheKey: "${playerController.currentSong.value!.id}_song",
                  )
            : Container(),
      ),
    );
  }
}
