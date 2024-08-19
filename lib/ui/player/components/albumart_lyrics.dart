import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';

import '../../widgets/image_widget.dart';
import '../../widgets/loader.dart';
import '../../widgets/sleep_timer_bottom_sheet.dart';
import '../../widgets/songinfo_bottom_sheet.dart';

class AlbumArtNLyrics extends StatelessWidget {
  const AlbumArtNLyrics({super.key, required this.playerArtImageSize});
  final double playerArtImageSize;

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final size = MediaQuery.of(context).size;
    //double playerArtImageSize = size.width - ((size.height < 750) ? 90 : 60);
    return Obx(() => playerController.currentSong.value != null
        ? Stack(
            children: [
              InkWell(
                onLongPress: () {
                  showModalBottomSheet(
                    constraints: const BoxConstraints(maxWidth: 500),
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10.0)),
                    ),
                    isScrollControlled: true,
                    context:
                        playerController.homeScaffoldkey.currentState!.context,
                    barrierColor: Colors.transparent.withAlpha(100),
                    builder: (context) => SongInfoBottomSheet(
                      playerController.currentSong.value!,
                      calledFromPlayer: true,
                    ),
                  ).whenComplete(() => Get.delete<SongInfoController>());
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
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Stack(
                          children: [
                            Obx(
                              () => playerController.isLyricsLoading.isTrue
                                  ? const Center(
                                      child: LoadingIndicator(),
                                    )
                                  : playerController.lyricsMode.toInt() == 1
                                      ? Center(
                                          child: SingleChildScrollView(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 0,
                                                vertical:
                                                    playerArtImageSize / 3.5),
                                            child: Obx(
                                              () => Text(
                                                playerController.lyrics[
                                                            "plainLyrics"] ==
                                                        "NA"
                                                    ? "lyricsNotAvailable".tr
                                                    : playerController
                                                        .lyrics["plainLyrics"],
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                      : IgnorePointer(
                                          child: LyricsReader(
                                            padding: const EdgeInsets.only(
                                                left: 5, right: 5),
                                            lyricUi: playerController.lyricUi,
                                            position: playerController
                                                .progressBarStatus
                                                .value
                                                .current
                                                .inMilliseconds,
                                            model: LyricsModelBuilder.create()
                                                .bindLyricToMain(
                                                    playerController
                                                        .lyrics['synced']
                                                        .toString())
                                                .getModel(),
                                            emptyBuilder: () => Center(
                                              child: Text(
                                                "syncedLyricsNotAvailable".tr,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                            ),
                            IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
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
                                    stops: const [0, 0.2, 0.5, 0.8, 1],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
              if (playerController.isSleepTimerActive.isTrue)
                SizedBox(
                  width: playerArtImageSize,
                  height: playerArtImageSize,
                  //color: Colors.green,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50,
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(width: 1.3, color: Colors.white),
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(150)),
                        child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              constraints: const BoxConstraints(maxWidth: 500),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10.0)),
                              ),
                              isScrollControlled: true,
                              context: playerController
                                  .homeScaffoldkey.currentState!.context,
                              barrierColor: Colors.transparent.withAlpha(100),
                              builder: (context) =>
                                  const SleepTimerBottomSheet(),
                            );
                          },
                          icon: const Icon(
                            Icons.timer,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          )
        : Container());
  }
}
