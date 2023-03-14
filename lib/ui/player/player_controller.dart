import 'dart:developer';
import 'package:harmonymusic/ui/utils/home_library_controller.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:get/get.dart';

import '/models/durationstate.dart';
import '/services/music_service.dart';
import '/services/song_stream_url_service.dart';
import '../../models/song.dart';

class PlayerController extends GetxController {
  final _audioHandler = Get.find<AudioHandler>();
  final _songUriService = SongUriService();
  final currentQueue = [].obs;

  final MusicServices _musicServices = MusicServices();
  final playerPaneOpacity = (1.0).obs;
  final isPlayerpanelTopVisible = true.obs;
  final isPlayerPaneDraggable = true.obs;
  final playerPanelMinHeight = 0.0.obs;
  bool _initFlagForPlayer = true;
  PanelController playerPanelController = PanelController();
  HomeLibrayController homeLibrayController = Get.find<HomeLibrayController>();

  final progressBarStatus = ProgressBarState(
          buffered: Duration.zero, current: Duration.zero, total: Duration.zero)
      .obs;

  final currentSongIndex = (0).obs;
  final isFirstSong = true;
  final isLastSong = true;
  final isShuffleModeEnabled = false.obs;
  final currentSong = Rxn<Song>();

  final buttonState = PlayButtonState.paused.obs;

  var _newSongFlag = true;
  final isCurrentSongBuffered = false.obs;

  final _songsUrlCacheBox = Hive.box("SongsUrlCache");
  final _songsCacheBox = Hive.box("SongsCache");

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
      if (playbackState.bufferedPosition.inSeconds /
              progressBarStatus.value.total.inSeconds ==
          1) {
        if (_newSongFlag) {
          _checkWithCacheDb(currentSong.value!);
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

  void _checkWithCacheDb(Song song) {
    //print("cached in database");
    if (!_songsCacheBox.containsKey(song.songId)) {
      _songsCacheBox.put(song.songId, song);
      if (!homeLibrayController.isClosed) {
        homeLibrayController.cachedSongsList.value =
            homeLibrayController.cachedSongsList.value + [song];
      }
    }
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
        _newSongFlag = true;
        isCurrentSongBuffered.value = false;
        currentSong.value = Song.fromMediaItem(mediaItem);
        currentSongIndex.value = currentQueue.indexWhere(
            (element) => element.songId == currentSong.value!.songId);
      }
    });
  }

  void _listenForPlaylistChange() {
    _audioHandler.queue.listen((queue) {
      //inspect(queue);
      //print("Queue length${queue.}");
      currentQueue.value = queue
          .map<Song?>((mediaItem) => Song.fromJson(mediaItem.extras!['song']))
          .whereType<Song>()
          .toList();
    });
  }

  ///pushSongToPlaylist method clear previous song queue, plays the tapped song and push related
  ///songs into Queue
  Future<void> pushSongToQueue(Song song) async {
    currentSong.value = song;
    removeAll(currentQueue.value.length);
    //open player panel,set current song and push first song into playing list,
    enqueueSong(song);
    _audioHandler.play();
    _playerPanelCheck();

    final response =
        await _musicServices.getWatchPlaylist(videoId: song.songId);
    List<Song> upNextSongList =
        (response['tracks']).map<Song>((item) => Song.fromJson(item)).toList();

    enqueueSongList(upNextSongList.sublist(1));
  }

  ///enqueueSong   append a song to current queue
  ///if current queue is empty, push the song into Queue and play that song
  Future<void> enqueueSong(Song song) async {
    //check if song is available in cache and allocate
    if (_songsCacheBox.containsKey(song.songId)) {
      _audioHandler.addQueueItem(
          (_songsCacheBox.get(song.songId) as Song).toMediaItem());
      return;
    }

    //check if song stream url is cached and allocate url accordingly
    String url = "";
    if (_songsUrlCacheBox.containsKey(song.songId)) {
      if (_isUrlExpired(_songsUrlCacheBox.get(song.songId))) {
        url = (await _songUriService.getSongUri(song.songId)).toString();
        _songsUrlCacheBox.put(song.songId, url);
      } else {
        url = _songsUrlCacheBox.get(song.songId);
      }
    } else {
      url = (await _songUriService.getSongUri(song.songId)).toString();
      _songsUrlCacheBox.put(song.songId, url);
    }
    _audioHandler.addQueueItem(song.toMediaItem(manUrl: url));

    //check if this is first song in queue then play
    if (await _audioHandler.queue.length == 1) {
      currentSong.value = song;
      _playerPanelCheck();
      _audioHandler.play();
    }
  }

  ///Check if Steam Url is expired
  bool _isUrlExpired(String url) {
    RegExpMatch? match = RegExp(".expire=([0-9]+)?&").firstMatch(url);
    if (match != null) {
      if(DateTime.now().millisecondsSinceEpoch~/1000+1800<int.parse(match[1]!)){
        print("Not Expired");
        return false;
      }
    }
    return true;
  }

  ///enqueueSongList method add song List to current queue
  ///if queue is empty,song start playing automatically
  Future<void> enqueueSongList(List<Song> songs) async {
    for (Song song in songs) {
      enqueueSong(song);
    }

    if (await _audioHandler.queue.length == songs.length) {
      currentSong.value = songs[0];
      _playerPanelCheck();
      _audioHandler.play();
    }
  }

  Future<void> playPlayListSong(List<Song> songs, int index) async {
    Song songToPlay = songs[index];
    currentSong.value = songToPlay;
    removeAll(currentQueue.value.length);
    songs.remove(songToPlay);
    //open player pane,set current song and push first song into playing list,
    _playerPanelCheck();
    enqueueSong(songToPlay);
    _audioHandler.play();
    enqueueSongList(songs);
  }

  void removeAll(int length) {
    for (int i = 0; i < length; i++) {
      remove();
    }
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
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

  void test() async {
    print("Here");
    await _songUriService.test();
  }
}

enum PlayButtonState { paused, playing, loading }
