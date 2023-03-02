import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/durationstate.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/services/song_stream_url_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/song.dart';
import '../../models/thumbnail.dart' as thumb;

class PlayerController extends GetxController {
  final _audioHandler = Get.find<AudioHandler>();
  final _songUriService = SongUriService();
  //var currentQueue = [].obs;
  final playlistSongsDetails = [].obs;

  final MusicServices _musicServices = MusicServices();
  final playerPaneOpacity = (1.0).obs;
  final isPlayerpanelTopVisible = true.obs;
  final isPlayerPaneDraggable = true.obs;
  final playerPanelMinHeight = 0.0.obs;
  bool _initFlagForPlayer = true;
  PanelController playerPanelController = PanelController();

  // late AudioPlayer _audioPlayer;
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
    //_audioPlayer = AudioPlayer();
    _listenForChangesInPlayerState();
    _listenForChangesInPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInDuration();
    _listenForCurrentSong();
    _listenForPlaylistChange();
  }

  void panellistener(double x) {
    if (x >= 0 && x <= 0.2) {
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
    _audioHandler.playbackState.listen((playerState) {
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
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenForChangesInPosition() {
    AudioService.position.listen((position) {
      final oldState = progressBarStatus.value;
      progressBarStatus.update((val) {
        val!.current = position;
        val.buffered = oldState.buffered;
        val.total = oldState.total;
      });
    });
  }

  void _listenForChangesInBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressBarStatus.value;
      progressBarStatus.update((val) {
        val!.buffered = playbackState.bufferedPosition;
        val.current = oldState.current;
        val.total = oldState.total;
      });
    });
  }

  void _listenForChangesInDuration() {
    _audioHandler.mediaItem.listen((mediaitem) {
      final oldState = progressBarStatus.value;
      progressBarStatus.update((val) {
        val!.total = mediaitem?.duration ?? Duration.zero;
        val.current = oldState.current;
        val.buffered = oldState.buffered;
      });
    });
  }

  Future<void> pushSongToPlaylist(Song song) async {
    //removed after implementation
    // playlistSongsDetails.clear();
    //currentQueue.clear();

    //open player pane,set current song and push first song into playing list,
    if (playerPanelController.isAttached) {
      playerPanelController.open();
    }
  
    currentSong.value = song;
    //playlistSongsDetails.add(song);
    //currentQueue.add(song);
    

    //get first song url and set to player
    Uri songUri = await _songUriService.getSongUri(song.songId);
    //print(songUri.toString());
    //inspect(song);
    _audioHandler.updateQueue([MediaItem(
        id: song.songId,
        title: song.title,
        artUri: Uri.parse(song.thumbnail.sizewith(100)),
        artist: song.artist[0]['name'],
        extras: {'url': songUri.toString(), 'song': song.toJson()})]);
    _audioHandler.play();

    if (_initFlagForPlayer) {
      playerPanelMinHeight.value = 75;
      _initFlagForPlayer = false;
    }

    final response =
        await _musicServices.getWatchPlaylist(videoId: song.songId);
    List<Song> upNextSongList =
        (response['tracks']).map<Song>((item) => Song.fromJson(item)).toList();
    //playlistSongsDetails.addAll([...upNextSongList.sublist(1)]);

    //Load Url of Songs other than first song
    for (int i = 1; i < upNextSongList.length; i++) {
      Uri songUri = await _songUriService.getSongUri(upNextSongList[i].songId);
      _audioHandler.addQueueItem(MediaItem(
          id: upNextSongList[i].songId,
          title: upNextSongList[i].title,
          artUri: Uri.parse(upNextSongList[i].thumbnail.sizewith(200)),
          artist: upNextSongList[i].artist[0]['name'],
          extras: {
            'url': songUri.toString(),
            'song': upNextSongList[i].toJson()
          }));
    }
  }

  void _listenForCurrentSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        currentSong.value = Song.fromJson(mediaItem.extras!['song']);
        currentSongIndex.value = playlistSongsDetails.indexWhere(
            (element) => element.songId == currentSong.value!.songId);
      }
    });
  }

  void _listenForPlaylistChange() {
    _audioHandler.queue.listen((queue) {
      //inspect(queue);
      //print("Queue length${queue.}");
      playlistSongsDetails.value = queue
          .map<Song?>((mediaItem) => Song.fromJson(mediaItem.extras!['song']))
          .whereType<Song>()
          .toList();
      //   playlistSongsDetails.setAll(0,
      //       queue.map<Song?>((mediaItem) => Song.fromJson(mediaItem.extras!['song'])).toList().whereType<Song>());
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
    _audioHandler.play();
  }

  void pause() {
    _audioHandler.pause();
  }

  void prev() {
    _audioHandler.skipToPrevious();
  }

  void next() {
    _audioHandler.skipToNext();
  }

  void seek(Duration position) {
    _audioHandler.seek(position);
  }

  void seekByIndex(int index) {
    _audioHandler.skipToQueueItem(index);
  }

  void toggleShuffleMode() {
    isShuffleModeEnabled.value
        ? _audioHandler.setShuffleMode(AudioServiceShuffleMode.all)
        : _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    isShuffleModeEnabled.value = !isShuffleModeEnabled.value;
  }

  void clearPlaylist() {
    for (int i = 0; i < _audioHandler.queue.value.length; i++) {
      _audioHandler.removeQueueItemAt(i);
    }
  }

  void replay() {
    _audioHandler;
  }

  @override
  void dispose() {
    _audioHandler.customAction('dispose');
    super.dispose();
  }
}

enum PlayButtonState { paused, playing, loading }
