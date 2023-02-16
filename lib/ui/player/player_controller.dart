import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/durationstate.dart';
import 'package:harmonymusic/services/api.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/services/song_stream_url_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/song.dart';

class PlayerController extends GetxController {
  late ConcatenatingAudioSource _playlist ;

  final playlistSongsDetails = [].obs;

  final MusicServices _musicServices = MusicServices();

  late AudioPlayer _audioPlayer;

  final progressBarStatus = ProgressBarState(
          buffered: Duration.zero, current: Duration.zero, total: Duration.zero)
      .obs;

  final currentSongIndex = (0).obs;
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
    _listenForChangesInPlayerState();
    _listenForChangesInPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInDuration();
    _listenForChangesInSequenceState();
  }

  void _listenForChangesInPlayerState() {
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
    });
  }

  void _listenForChangesInPosition() {
    _audioPlayer.positionStream.listen((position) {
      final oldState = progressBarStatus.value;
      progressBarStatus.update((val) {
        val!.current = position;
        val.buffered = oldState.buffered;
        val.total = oldState.total;
      });
    });
  }

  void _listenForChangesInBufferedPosition() {
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressBarStatus.value;
      progressBarStatus.update((val) {
        val!.buffered = bufferedPosition;
        val.current = oldState.current;
        val.total = oldState.total;
      });
    });
  }

  void _listenForChangesInDuration() {
    _audioPlayer.durationStream.listen((duration) {
      final oldState = progressBarStatus.value;
      progressBarStatus.update((val) {
        val!.total = duration ?? Duration.zero;
        val.current = oldState.current;
        val.buffered = oldState.buffered;
      });
    });
  }

  Future<void> pushSongToPlaylist(List<Song> songs) async {
    final firstSongStreamUrl = await SongStreamUrlService(song: songs[0]).songStreamUrl;

    

     _playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: [
        AudioSource.uri(Uri.parse(firstSongStreamUrl["48 kbps"]))
      ],
    );
      await _audioPlayer.setAudioSource(_playlist);
      playlistSongsDetails.add(songs[0]);
      _audioPlayer.play();


      //Load Url of Songs other than first song
      for (int i = 1; i < songs.length; i++) {
      final songStreamUrl =
          await SongStreamUrlService(song: songs[i]).songStreamUrl;
      _playlist.add(AudioSource.uri(Uri.parse(songStreamUrl["48 kbps"])));
      playlistSongsDetails.add(songs[i]);
    }

  }

  void _listenForChangesInSequenceState() {
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;
      print("here index ${sequenceState.currentIndex}");
      currentSongIndex.value = sequenceState.currentIndex;
    });
  }

  Song get currentSong {
    return playlistSongsDetails[currentSongIndex.value];
  }

  Future<void> play() async {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void prev() {
    _audioPlayer.hasPrevious ? _audioPlayer.seekToPrevious() : null;
  }

  void next() {
    _audioPlayer.hasNext ? _audioPlayer.seekToNext() : null;
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
