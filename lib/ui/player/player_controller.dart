import 'dart:convert';
import 'dart:developer';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/durationstate.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/services/song_stream_url_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/song.dart';

class PlayerController extends GetxController {
  final playlist = ConcatenatingAudioSource(
    useLazyPreparation: true,
    shuffleOrder: DefaultShuffleOrder(),
    children: [],
  );
  var currentQueue = [].obs;
  final playlistSongsDetails = [].obs;

  final MusicServices _musicServices = MusicServices();
  final playerPaneOpacity = (1.0).obs;
  final isPlayerpanelTopVisible = true.obs;
  final isPlayerPaneDraggable = true.obs;
  final playerPanelMinHeight = 0.0.obs;
  bool _initFlagForPlayer = true;
  PanelController playerPanelController = PanelController();

  late AudioPlayer _audioPlayer;
  late YoutubeExplode _yt;
  final progressBarStatus = ProgressBarState(
          buffered: Duration.zero, current: Duration.zero, total: Duration.zero)
      .obs;

  final currentSongIndex = (0).obs;
  final isFirstSong = true;
  final isLastSong = true;
  final isShuffleModeEnabled = false.obs;
  final currentSong = Rxn<Song>();

  final buttonState = PlayButtonState.paused.obs;

  PlayerController() {
    _init();
  }

  void _init() async {
    _audioPlayer = AudioPlayer();
    _yt = YoutubeExplode();
    _listenForChangesInPlayerState();
    _listenForChangesInPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInDuration();
    _listenForChangesInSequenceState();
  }

  void panellistener(double x) {
    if (x >= 0 && x <= 0.2) {
      //print(1 - (x*5));
      playerPaneOpacity.value = 1 - (x * 5);
      isPlayerpanelTopVisible.value = true;
    }
    if (x > 0.2) {
      isPlayerpanelTopVisible.value = false;
    }
    if (x > 0) {
      isPlayerPaneDraggable.value = false;
    } else {
      isPlayerPaneDraggable.value = true;
    }
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

  Future<void> pushSongToPlaylist(Song song) async {
    //removed after implementation
    playlistSongsDetails.clear();
    playlist.clear();
    currentQueue.clear();

    //open player pane,set current song and push first song into playing list,
    if (playerPanelController.isAttached) {
      playerPanelController.open();
    }
    currentSong.value = song;
    playlistSongsDetails.add(song);
    currentQueue.add(song);

    //get first song url and set to player
    final firstSongtreamManifest =
        await _yt.videos.streamsClient.getManifest(song.songId);
    final streamUri = firstSongtreamManifest.audioOnly.sortByBitrate()[0].url;
    playlist.add(AudioSource.uri(streamUri, tag: song));
    await _audioPlayer.setAudioSource(playlist, preload: true);
    _audioPlayer.play();

    if (_initFlagForPlayer) {
      playerPanelMinHeight.value = 75;
      _initFlagForPlayer = false;
    }

    final response =
        await _musicServices.getWatchPlaylist(videoId: song.songId);
    List<Song> upNextSongList =
        (response['tracks']).map<Song>((item) => Song.fromJson(item)).toList();
    playlistSongsDetails.addAll([...upNextSongList.sublist(1)]);

    //Load Url of Songs other than first song
    List<AudioSource> tempList = [];
    for (int i = 1; i < upNextSongList.length; i++) {
      final streamManifest =
          await _yt.videos.streamsClient.getManifest(upNextSongList[i].songId);
      tempList.add(AudioSource.uri(
          (streamManifest.audioOnly.sortByBitrate()[0].url),
          tag: upNextSongList[i]));
    }
    playlist.addAll([...tempList]);
  }

  void _listenForChangesInSequenceState() {
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null && sequenceState!.effectiveSequence.isEmpty)
        return;
      currentQueue.value = [...(sequenceState.sequence).map((e) => e.tag)];
      currentSong.value = sequenceState.currentSource?.tag;
      currentSongIndex.value = sequenceState.currentIndex;
    });
  }

  Future<void> testSong(String videoId) async {
    print(videoId);
    final response = await _musicServices.getWatchPlaylist(videoId: videoId);
    List<Song> upNextSongList =
        (response['tracks']).map<Song>((item) => Song.fromJson(item)).toList();
    inspect(upNextSongList);
  }

  void play() {
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

  void seekByIndex(int index) {
    _audioPlayer.seek(Duration.zero, index: index);
  }

  void toggleShuffleMode() {
    _audioPlayer.setShuffleModeEnabled(!isShuffleModeEnabled.value);
    isShuffleModeEnabled.value = !isShuffleModeEnabled.value;
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
