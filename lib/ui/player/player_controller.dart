import 'dart:developer';

import 'package:harmonymusic/models/media_Item_builder.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:get/get.dart';

import '/models/durationstate.dart';
import '/services/music_service.dart';

class PlayerController extends GetxController {
  final _audioHandler = Get.find<AudioHandler>();
  final _musicServices = Get.find<MusicServices>();
  final currentQueue = [].obs;

  final playerPaneOpacity = (1.0).obs;
  final isPlayerpanelTopVisible = true.obs;
  final isPlayerPaneDraggable = true.obs;
  final playerPanelMinHeight = 0.0.obs;
  bool _initFlagForPlayer = true;
  PanelController playerPanelController = PanelController();

  final progressBarStatus = ProgressBarState(
          buffered: Duration.zero, current: Duration.zero, total: Duration.zero)
      .obs;

  final currentSongIndex = (0).obs;
  final isFirstSong = true;
  final isLastSong = true;
  final isShuffleModeEnabled = false.obs;
  final currentSong = Rxn<MediaItem>();

  final buttonState = PlayButtonState.paused.obs;

  var _newSongFlag = true;
  final isCurrentSongBuffered = false.obs;
  late final _appdocdir;

  PlayerController() {
    _init();
  }

  void _init() async {
    //_createAppDocDir();
    _listenForChangesInPlayerState();
    _listenForChangesInPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInDuration();
    _listenForCurrentSong();
    _listenForPlaylistChange();
  }

  Future<void> _createAppDocDir() async {
    _appdocdir = (await getApplicationDocumentsDirectory()).path;
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
      if (playbackState.bufferedPosition.inSeconds /
              progressBarStatus.value.total.inSeconds ==
          1) {
        if (_newSongFlag) {
          _audioHandler.customAction(
              "checkWithCacheDb", {'mediaItem': currentSong.value!});
          _newSongFlag = false;
        }
      }
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

  void _listenForCurrentSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        print(mediaItem.title);
        _newSongFlag = true;
        isCurrentSongBuffered.value = false;
        currentSong.value = mediaItem;
        currentSongIndex.value = currentQueue
            .indexWhere((element) => element.id == currentSong.value!.id);
      }
    });
  }

  void _listenForPlaylistChange() {
    _audioHandler.queue.listen((queue) {
      currentQueue.value = queue;
    });
  }

  ///pushSongToPlaylist method clear previous song queue, plays the tapped song and push related
  ///songs into Queue
  Future<void> pushSongToQueue(MediaItem mediaItem) async {
    //open player panel,set current song and push first song into playing list,
    currentSong.value = mediaItem;
    final init = _initFlagForPlayer;
    _audioHandler.customAction('setSourceNPlay', {'mediaItem': mediaItem});
    _playerPanelCheck();
    final response =
        await _musicServices.getWatchPlaylist(videoId: mediaItem.id);
    List<MediaItem> upNextSongList = (response['tracks'])
        .map<MediaItem>((item) => MediaItemBuilder.fromJson(item))
        .toList();

    inspect(upNextSongList);
    await _audioHandler.updateQueue(upNextSongList);
  }

  ///enqueueSong   append a song to current queue
  ///if current queue is empty, push the song into Queue and play that song
  Future<void> enqueueSong(MediaItem mediaItem) async {
    //check if song is available in cache and allocate
    await _audioHandler.addQueueItem(mediaItem);
  }

  ///enqueueSongList method add song List to current queue
  ///if queue is empty,song start playing automatically
  Future<void> enqueueSongList(List<MediaItem> mediaItems) async {}

  Future<void> playPlayListSong(List<MediaItem> mediaItems, int index) async {
    //open player pane,set current song and push first song into playing list,
    final init = _initFlagForPlayer;
    currentSong.value = mediaItems[index];
    _playerPanelCheck();
    !init
        ? await _audioHandler.updateQueue(mediaItems)
        : _audioHandler.addQueueItems(mediaItems);
    await _audioHandler.customAction("playByIndex", {"index": index});
  }

  void _playerPanelCheck() {
    if (playerPanelController.isAttached) {
      playerPanelController.open();
    }

    if (_initFlagForPlayer) {
      playerPanelMinHeight.value = 75.0 + Get.mediaQuery.viewPadding.bottom;
      _initFlagForPlayer = false;
    }
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

  Future<void> next() async {
    await _audioHandler.skipToNext();
  }

  void seek(Duration position) {
    _audioHandler.seek(position);
  }

  void seekByIndex(int index) {
    _audioHandler.customAction("playByIndex", {"index": index});
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
