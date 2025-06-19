import 'package:get/get.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:smtc_windows/smtc_windows.dart';

import '../ui/player/player_controller.dart';

class WindowsAudioService extends GetxService {
  late SMTCWindows smtc;
  final playerController = Get.find<PlayerController>();

  @override
  void onInit() {
    _initService();
    super.onInit();
  }

  _initService() {
    smtc = SMTCWindows(
      enabled: false,
    );
    try {
      smtc.buttonPressStream.listen((event) {
        switch (event) {
          case PressedButton.play:
            playerController.play();
            smtc.setPlaybackStatus(PlaybackStatus.Playing);
            break;
          case PressedButton.pause:
            playerController.pause();
            smtc.setPlaybackStatus(PlaybackStatus.Paused);
            break;
          case PressedButton.next:
            playerController.next();
            break;
          case PressedButton.previous:
            playerController.prev();
            break;

          default:
            break;
        }
      });
    } catch (e) {
      printERROR("Error: $e");
    }

    playerController.buttonState.listen((state) {
      switch (state) {
        case PlayButtonState.playing:
          smtc.setPlaybackStatus(PlaybackStatus.Playing);
          break;
        case PlayButtonState.paused:
          smtc.setPlaybackStatus(PlaybackStatus.Paused);
          break;
        case PlayButtonState.loading:
          smtc.setPlaybackStatus(PlaybackStatus.Paused);
          break;
      }
    });

    playerController.progressBarStatus.listen((status) {
      smtc.setPosition(status.current);
    });

    playerController.currentSong.listen((song) async {
      if (song != null) {
        if (!smtc.enabled) await smtc.enableSmtc();
        await smtc.updateMetadata(
          MusicMetadata(
            title: song.title,
            album: song.album,
            albumArtist: song.artist,
            artist: song.artist,
            thumbnail: song.artUri.toString(),
          ),
        );
        smtc.setEndTime(playerController.progressBarStatus.value.total);
      }
    });
  }

  @override
  void onClose() {
    smtc.clearMetadata();
    smtc.disableSmtc();
    smtc.dispose();
    super.onClose();
  }
}
