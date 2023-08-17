import 'dart:async';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../../utils/helper.dart';
import '/models/media_Item_builder.dart';
import '/ui/screens/home_screen_controller.dart';
import '/ui/screens/playlistnalbum_screen_controller.dart';
import '../widgets/sliding_up_panel.dart';
import '/models/durationstate.dart';
import '/services/music_service.dart';

class PlayerController extends GetxController {
  final _audioHandler = Get.find<AudioHandler>();
  final _musicServices = Get.find<MusicServices>();
  final currentQueue = <MediaItem>[].obs;

  final playerPaneOpacity = (1.0).obs;
  final isPlayerpanelTopVisible = true.obs;
  final isPlayerPaneDraggable = true.obs;
  final playerPanelMinHeight = 0.0.obs;
  bool _initFlagForPlayer = true;
  final isQueueReorderingInProcess = false.obs;
  PanelController playerPanelController = PanelController();
  bool isRadioModeOn = false;
  String? radioContinuationParam;
  dynamic radioInitiatorItem;

  final progressBarStatus = ProgressBarState(
          buffered: Duration.zero, current: Duration.zero, total: Duration.zero)
      .obs;

  final currentSongIndex = (0).obs;
  final isFirstSong = true;
  final isLastSong = true;
  final isLoopModeEnabled = false.obs;
  final currentSong = Rxn<MediaItem>();
  final isCurrentSongFav = false.obs;
  final showLyricsflag = false.obs;
  final isLyricsLoading = false.obs;
  final lyrics = "".obs;
  ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> homeScaffoldkey = GlobalKey<ScaffoldState>();

  final buttonState = PlayButtonState.paused.obs;

  var _newSongFlag = true;
  final isCurrentSongBuffered = false.obs;

  late StreamSubscription<bool> keyboardSubscription;

  PlayerController() {
    _init();
  }

  void _init() async {
    //_createAppDocDir();
    _listenForChangesInPlayerState();
    _listenForChangesInPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInDuration();
    _listenForPlaylistChange();
    _listenForKeyboardActivity();
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

  void _listenForKeyboardActivity() {
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      visible ? playerPanelController.hide() : playerPanelController.show();
    });
  }

  void _listenForChangesInPlayerState() {
    _audioHandler.playbackState.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        buttonState.value = PlayButtonState.loading;
      } else if (!isPlaying) {
        buttonState.value = PlayButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
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
    _audioHandler.mediaItem.listen((mediaItem) async {
      final oldState = progressBarStatus.value;
      progressBarStatus.update((val) {
        val!.total = mediaItem?.duration ?? Duration.zero;
        val.current = oldState.current;
        val.buffered = oldState.buffered;
      });
      if (mediaItem != null) {
        printINFO(mediaItem.title);
        _newSongFlag = true;
        isCurrentSongBuffered.value = false;
        currentSong.value = mediaItem;
        currentSongIndex.value = currentQueue
            .indexWhere((element) => element.id == currentSong.value!.id);
        await _checkFav();
        await _addToRP(currentSong.value!);
        if (isRadioModeOn && (currentSong.value!.id == currentQueue.last.id)) {
          await _addRadioContinuation(radioInitiatorItem!);
        }
        lyrics.value = "";
        showLyricsflag.value = false;
      }
    });
  }

  void _listenForPlaylistChange() {
    _audioHandler.queue.listen((queue) {
      currentQueue.value = queue;
      currentQueue.refresh();
    });
  }

  ///pushSongToPlaylist method clear previous song queue, plays the tapped song and push related
  ///songs into Queue
  Future<void> pushSongToQueue(MediaItem? mediaItem,
      {String? playlistid, bool radio = false}) async {
    isRadioModeOn = radio;

    Future.delayed(
      Duration.zero,
      () async {
        final content = await _musicServices.getWatchPlaylist(
            videoId: mediaItem != null ? mediaItem.id : "",
            radio: radio,
            playlistId: playlistid);
        radioContinuationParam = content['additionalParamsForNext'];
        await _audioHandler
            .updateQueue(List<MediaItem>.from(content['tracks']));
      },
    ).then((value) async {
      if (playlistid != null) {
        _playerPanelCheck();
        await _audioHandler.customAction("playByIndex", {"index": 0});
      } else {
        if (Hive.box("AppPrefs").get("discoverContentType") == "BOLI") {
          Get.find<HomeScreenController>()
              .changeDiscoverContent("BOLI", songId: mediaItem!.id);
        }
      }
    });

    if (playlistid != null) {
      return;
    }

    currentSong.value = mediaItem;
    _playerPanelCheck();
    await _audioHandler
        .customAction("setSourceNPlay", {'mediaItem': mediaItem});
  }

  Future<void> playPlayListSong(List<MediaItem> mediaItems, int index) async {
    isRadioModeOn = false;
    //open player pane,set current song and push first song into playing list,
    final init = _initFlagForPlayer;
    currentSong.value = mediaItems[index];

    //for changing home content based on last interation
    Future.delayed(const Duration(seconds: 3), () {
      if (Hive.box("AppPrefs").get("discoverContentType") == "BOLI") {
        Get.find<HomeScreenController>()
            .changeDiscoverContent("BOLI", songId: mediaItems[index].id);
      }
    });

    _playerPanelCheck();
    !init
        ? await _audioHandler.updateQueue(mediaItems)
        : _audioHandler.addQueueItems(mediaItems);
    await _audioHandler.customAction("playByIndex", {"index": index});
  }

  Future<void> startRadio(MediaItem? mediaItem, {String? playlistid}) async {
    radioInitiatorItem = mediaItem ?? playlistid;
    await pushSongToQueue(mediaItem, playlistid: playlistid, radio: true);
  }

  Future<void> _addRadioContinuation(dynamic item) async {
    final isSong = item.runtimeType.toString() == "MediaItem";
    final content = await _musicServices.getWatchPlaylist(
        videoId: isSong ? item.id : "",
        radio: true,
        limit: 24,
        playlistId: isSong ? null : item,
        additionalParamsNext: radioContinuationParam);
    radioContinuationParam = content['additionalParamsForNext'];
    await enqueueSongList(List<MediaItem>.from(content['tracks']));
  }

  ///enqueueSong   append a song to current queue
  ///if current queue is empty, push the song into Queue and play that song
  Future<void> enqueueSong(MediaItem mediaItem) async {
    //check if song is available in cache and allocate
    await enqueueSongList([mediaItem]);
  }

  ///enqueueSongList method add song List to current queue
  Future<void> enqueueSongList(List<MediaItem> mediaItems) async {
    if (currentQueue.isEmpty) {
      await playPlayListSong(mediaItems, 0);
      return;
    }
    for (MediaItem item in mediaItems) {
      if (!currentQueue.contains(item)) {
        _audioHandler.addQueueItem(item);
      }
    }
  }

  void playNext(MediaItem song) {
    if (currentQueue.isEmpty) {
      enqueueSong(song);
      return;
    }
    int index = -1;
    for (int i = 0; i < currentQueue.length; i++) {
      if (song.id == (currentQueue[i]).id) {
        index = i;
        break;
      }
    }
    final currentIndx = currentSongIndex.value;
    if (index == currentIndx) {
      return;
    }
    if (index != -1) {
      if (currentQueue.length == 1 ||
          (currentQueue.length == 2 && index == 1)) {
        return;
      }
      onReorder(index, currentSongIndex.value + 1);
    } else {
      //Will add song just below the current song
      (currentIndx == currentQueue.length - 1)
          ? enqueueSong(song)
          : _audioHandler.customAction("addPlayNextItem", {"mediaItem": song});
    }
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

  void removeFromQueue(MediaItem song) {
    _audioHandler.removeQueueItem(song);
  }

  void shuffleQueue() {
    _audioHandler.customAction("shuffleQueue");
  }

  void onReorder(int oldIndex, int newIndex) {
    _audioHandler.customAction(
        "reorderQueue", {"oldIndex": oldIndex, "newIndex": newIndex});
  }

  void onReorderStart(int index) {
    isQueueReorderingInProcess.value = true;
  }

  void onReorderEnd(int index) {
    isQueueReorderingInProcess.value = false;
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

  void toggleSkipSilence(bool enable) {
    _audioHandler.customAction("toggleSkipSilence", {"enable": enable});
  }

  void toggleLoopMode() {
    isLoopModeEnabled.isFalse
        ? _audioHandler.setRepeatMode(AudioServiceRepeatMode.one)
        : _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
    isLoopModeEnabled.value = !isLoopModeEnabled.value;
  }

  Future<void> _checkFav() async {
    isCurrentSongFav.value =
        (await Hive.openBox("LIBFAV")).containsKey(currentSong.value!.id);
  }

  Future<void> toggleFavourite() async {
    final currMediaItem = currentSong.value!;
    final box = await Hive.openBox("LIBFAV");
    isCurrentSongFav.isFalse
        ? box.put(currMediaItem.id, MediaItemBuilder.toJson(currMediaItem))
        : box.delete(currMediaItem.id);
    try {
      final playlistController = Get.find<PlayListNAlbumScreenController>();
      if (!playlistController.isAlbum &&
          playlistController.id == "LIBFAV") {
        isCurrentSongFav.isFalse
            ? playlistController.addNRemoveItemsinList(currMediaItem,
                action: 'add', index: 0)
            : playlistController.addNRemoveItemsinList(currMediaItem,
                action: 'remove');
      }
      // ignore: empty_catches
    } catch (e) {}
    isCurrentSongFav.value = !isCurrentSongFav.value;
  }

  // ignore: prefer_typing_uninitialized_variables
  var recentItem;

  /// This function is used to add a mediaItem/Song to Recently played playlist
  Future<void> _addToRP(MediaItem mediaItem) async {
    final box = await Hive.openBox("LIBRP");
    if (box.keys.length > 20) box.deleteAt(0);
    if (recentItem != mediaItem) {
      box.add(MediaItemBuilder.toJson(mediaItem));
      try {
        final playlistController = Get.find<PlayListNAlbumScreenController>();
        if (!playlistController.isAlbum &&
            playlistController.id == "LIBRP") {
          if (playlistController.songList.length > 20) {
            playlistController.addNRemoveItemsinList(null,
                action: 'remove',
                index: playlistController.songList.length - 1);
          }
          playlistController.addNRemoveItemsinList(mediaItem,
              action: 'add', index: 0);
        }
        // ignore: empty_catches
      } catch (e) {}
    }
    recentItem = mediaItem;
  }

  Future<void> showLyrics() async {
    showLyricsflag.value = !showLyricsflag.value;
    if (lyrics.isEmpty && showLyricsflag.value) {
      isLyricsLoading.value = true;
      final related = await _musicServices.getWatchPlaylist(
          videoId: currentSong.value!.id, onlyRelated: true);
      final relatedLyricsId = related['lyrics'];
      if (relatedLyricsId != null) {
        final lyrics_ = await _musicServices.getLyrics(relatedLyricsId);
        lyrics.value = lyrics_ as String;
      }else{
        lyrics.value = "NA";
      }
      isLyricsLoading.value = false;
    }
  }

  Future<void> openEqualizer() async {
    await _audioHandler.customAction("openEqualizer");
  }

  @override
  void dispose() {
    _audioHandler.customAction('dispose');
    keyboardSubscription.cancel();
    scrollController.dispose();
    super.dispose();
  }
}

enum PlayButtonState { paused, playing, loading }
