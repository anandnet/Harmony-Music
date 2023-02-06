import 'package:get/get.dart';
import 'package:harmonymusic/models/durationstate.dart';
import 'package:just_audio/just_audio.dart';

class PlayerController extends GetxController {
  static const url =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
  late AudioPlayer _audioPlayer;

  final progressBarStatus = ProgressBarState(
          buffered: Duration.zero, current: Duration.zero, total: Duration.zero)
      .obs;

  final buttonState = PlayButtonState.paused.obs;

  PlayerController() {
    _init();
  }

  void _init() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setUrl(url);
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonState.value = PlayButtonState.loading;
      } else if (!isPlaying) {
        buttonState.value = PlayButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        buttonState.value = PlayButtonState.playing;
      } else {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }

      _audioPlayer.positionStream.listen((position) {
        final oldState =progressBarStatus.value;
        progressBarStatus.update((val) {
          val!.current = position;
          val.buffered = oldState.buffered;
          val.total = oldState.total;
        });
      });

      _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
        final oldState = progressBarStatus.value;
        progressBarStatus.update((val) {
          val!.buffered = bufferedPosition;
          val.current = oldState.current;
          val.total = oldState.total;
        });
      });

      _audioPlayer.durationStream.listen((duration) {
        final oldState = progressBarStatus.value;
        progressBarStatus.update((val) {
          val!.total = duration ?? Duration.zero;
          val.current = oldState.current;
          val.buffered = oldState.buffered;
        });
      });
    });
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void prev() {
    _audioPlayer.hasPrevious ? _audioPlayer.seekToPrevious : null;
  }

  void next() {
    _audioPlayer.hasNext ? _audioPlayer.seekToNext : null;
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void replay(){
    _audioPlayer.seek(Duration.zero, index: _audioPlayer.effectiveIndices!.first);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

enum PlayButtonState { paused, playing, loading }
