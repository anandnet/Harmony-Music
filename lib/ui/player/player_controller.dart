import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/durationstate.dart';
import 'package:harmonymusic/services/api.dart';
import 'package:harmonymusic/ui/player/utils.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/music_model.dart';

class PlayerController extends GetxController {
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(
    useLazyPreparation: true,
    shuffleOrder: DefaultShuffleOrder(),
    children: [],
  );

  final playlistSongsDetails = [].obs;

  static const url =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
  late AudioPlayer _audioPlayer;

  final progressBarStatus = ProgressBarState(
          buffered: Duration.zero, current: Duration.zero, total: Duration.zero)
      .obs;

  final currentSongTitle = ''.obs;
  final playlist = [].obs;
  final isFirstSong = true;
  final isLastSong = true;
  final isShuffleModeEnabled = false;

  final buttonState = PlayButtonState.paused.obs;

  PlayerController() {
    _init();
  }

  void _init() async {
    _audioPlayer = AudioPlayer();
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
        final oldState = progressBarStatus.value;
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

  void pushSongToPlaylist() {
    getSongdata("32USguG8VNM",true).then((songDetailsResponse) async {
      final relatedSongList = await getRelatedSongsList(songDetailsResponse.jsonResponse);
      relatedSongList.insert(0, songDetailsResponse.song);
      final playlist = ConcatenatingAudioSource(
        // Start loading next item just before reaching it
        useLazyPreparation: true,
        // Customise the shuffle algorithm
        shuffleOrder: DefaultShuffleOrder(),
        // Specify the playlist items
        children: relatedSongList.map((song)=>AudioSource.uri(Uri.parse(song.audioStreams.first.url))).toList(),
      );
      await _audioPlayer.setAudioSource(playlist);
      playlistSongsDetails.value.add(relatedSongList);
      _audioPlayer.play();

    });
  }

  void play() {
    // print((_playlist.value.children.first));
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void prev() {
    _audioPlayer.hasPrevious ? _audioPlayer.seekToPrevious : null;
  }

  void next() {
    print(_audioPlayer.hasNext);
    _audioPlayer.seekToNext ;
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void replay() {
    _audioPlayer.seek(Duration.zero,
        index: _audioPlayer.effectiveIndices!.first);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

enum PlayButtonState { paused, playing, loading }
