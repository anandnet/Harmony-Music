import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:device_equalizer/device_equalizer.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/media_Item_builder.dart';
import 'package:harmonymusic/services/background_task.dart';
import 'package:harmonymusic/services/permission_service.dart';
import 'package:harmonymusic/services/utils.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';
import 'package:harmonymusic/ui/screens/Library/library_controller.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
// ignore: unused_import, implementation_imports, depend_on_referenced_packages
import 'package:media_kit/src/player/platform_player.dart' show MPVLogLevel;
import 'package:path_provider/path_provider.dart';

Future<AudioHandler> initAudioService() async {
  return AudioService.init(
    builder: MyAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationIcon: 'mipmap/ic_launcher_monochrome',
      androidNotificationChannelId: 'com.mycompany.myapp.audio',
      androidNotificationChannelName: 'Harmony Music Notification',
      androidNotificationOngoing: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with GetxServiceMixin {
  // ignore: prefer_typing_uninitialized_variables
  late final _cacheDir;
  late AudioPlayer _player;

  // ignore: prefer_typing_uninitialized_variables
  dynamic currentIndex;
  int currentShuffleIndex = 0;
  late String? currentSongUrl;
  bool isPlayingUsingLockCachingSource = false;
  bool loopModeEnabled = false;
  bool queueLoopModeEnabled = false;
  bool shuffleModeEnabled = false;
  bool loudnessNormalizationEnabled = false;

  // var networkErrorPause = false;
  bool isSongLoading = true;
  DeviceEqualizer? deviceEqualizer;

  // list of shuffled queue songs ids
  List<String> shuffledQueue = [];

  final _playList = ConcatenatingAudioSource(children: [], useLazyPreparation: false);
  LibrarySongsController librarySongsController = Get.find<LibrarySongsController>();

  MyAudioHandler() {
    if (GetPlatform.isWindows || GetPlatform.isLinux) {
      JustAudioMediaKit.title = 'Harmony music';
      JustAudioMediaKit.protocolWhitelist = const ['http', 'https', 'file'];
    }
    _player = AudioPlayer(
        audioLoadConfiguration: const AudioLoadConfiguration(
            androidLoadControl: AndroidLoadControl(
      maxBufferDuration: Duration(seconds: 120),
      bufferForPlaybackDuration: Duration(milliseconds: 50),
      bufferForPlaybackAfterRebufferDuration: Duration(seconds: 2),
    )));
    _createCacheDir();
    _addEmptyList();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenToPlaybackForNextSong();
    _listenForSequenceStateChanges();
    final appPrefsBox = Hive.box('appPrefs');
    _player.setSkipSilenceEnabled(appPrefsBox.get('skipSilenceEnabled'));
    loopModeEnabled = appPrefsBox.get('isLoopModeEnabled') ?? false;
    shuffleModeEnabled = appPrefsBox.get('isShuffleModeEnabled') ?? false;
    queueLoopModeEnabled = Hive.box('AppPrefs').get('queueLoopModeEnabled') ?? false;
    loudnessNormalizationEnabled = appPrefsBox.get('loudnessNormalizationEnabled') ?? false;
    _listenForDurationChanges();
    if (GetPlatform.isAndroid) {
      deviceEqualizer = DeviceEqualizer();
      _listenSessionIdStream();
    }
  }

  Future<void> _createCacheDir() async {
    _cacheDir = (await getTemporaryDirectory()).path;
    if (!Directory('$_cacheDir/cachedSongs/').existsSync()) {
      Directory('$_cacheDir/cachedSongs/').createSync(recursive: true);
    }
  }

  void _addEmptyList() {
    try {
      _player.setAudioSource(_playList);
    } catch (r) {
      printERROR(r.toString());
    }
  }

  void _listenSessionIdStream() {
    _player.androidAudioSessionIdStream.listen((int? id) {
      if (id != null) {
        deviceEqualizer?.initAudioEffect(id);
      }
    });
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: isSongLoading
            ? AudioProcessingState.loading
            : const {
                ProcessingState.idle: AudioProcessingState.idle,
                ProcessingState.loading: AudioProcessingState.loading,
                ProcessingState.buffering: AudioProcessingState.buffering,
                ProcessingState.ready: AudioProcessingState.ready,
                ProcessingState.completed: AudioProcessingState.completed,
              }[_player.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: shuffleModeEnabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: currentIndex,
      ));

      //print("set ${playbackState.value.queueIndex},${event.currentIndex}");
    }, onError: (Object e, StackTrace st) async {
      if (e is PlayerException) {
        printERROR('Error code: ${e.code}');
        printERROR('Error message: ${e.message}');
      } else {
        printERROR('An error occurred: $e');
        var curPos = _player.position;
        await _player.stop();

        if (isPlayingUsingLockCachingSource && e.toString().contains('Connection closed while receiving data')) {
          await _player.seek(curPos, index: 0);
          await _player.play();
          return;
        }

        //Workaround when 403 error encountered
        // customAction("playByIndex", {'index': currentIndex, 'newUrl': true})
        //     .whenComplete(() async {
        //   await _player.stop();
        //   if (currentSongUrl == null) {
        //     networkErrorPause = true;
        //   } else {
        //     _player.play();
        //   }
        // });
        customAction('playByIndex', {'index': currentIndex, 'newUrl': true});
        await _player.seek(curPos, index: 0);
      }
    });
  }

  void _listenToPlaybackForNextSong() {
    final playerDurationOffset = GetPlatform.isWindows
        ? 200
        : GetPlatform.isLinux
            ? 700
            : 0;
    _player.positionStream.listen((value) async {
      if (_player.duration != null && _player.duration?.inSeconds != 0) {
        if (value.inMilliseconds >= (_player.duration!.inMilliseconds - playerDurationOffset)) {
          await _triggerNext();
        }
      }
    });
  }

  Future<void> _triggerNext() async {
    if (loopModeEnabled) {
      await _player.seek(Duration.zero);
      if (!_player.playing) {
        _player.play();
      }
      return;
    }
    skipToNext();
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) async {
      final currQueue = queue.value;
      if (currentIndex == null || currQueue.isEmpty || duration == null) return;
      final currentSong = queue.value[currentIndex];
      if (currentSong.duration == null || currentIndex == 0) {
        final newMediaItem = currentSong.copyWith(duration: duration);
        mediaItem.add(newMediaItem);
      }
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // notify system
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);

    if (shuffleModeEnabled) {
      final mediaItemsIds = mediaItems.toList().map((item) => item.id).toList();
      final notPlayedshuffledQueue =
          shuffledQueue.isNotEmpty ? shuffledQueue.toList().sublist(currentShuffleIndex + 1) : shuffledQueue;
      notPlayedshuffledQueue.addAll(mediaItemsIds);
      notPlayedshuffledQueue.shuffle();
      shuffledQueue.replaceRange(currentShuffleIndex, shuffledQueue.length, notPlayedshuffledQueue);
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    final newQueue = this.queue.value..replaceRange(0, this.queue.value.length, queue);
    this.queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    if (shuffleModeEnabled) {
      shuffledQueue.add(mediaItem.id);
    }

    // notify system
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  AudioSource _createAudioSource(MediaItem mediaItem) {
    final url = mediaItem.extras!['url'] as String;
    if (url.contains('/cache') || (Get.find<SettingsScreenController>().cacheSongs.isTrue && url.contains('http'))) {
      printINFO('Playing Using LockCaching');
      isPlayingUsingLockCachingSource = true;
      return LockCachingAudioSource(
        Uri.parse(url),
        cacheFile: File('$_cacheDir/cachedSongs/${mediaItem.id}.mp3'),
        tag: mediaItem,
      );
    }

    printINFO('Playing Using AudioSource.uri');
    isPlayingUsingLockCachingSource = false;
    return AudioSource.uri(
      Uri.tryParse(url)!,
      tag: mediaItem,
    );
  }

  @override
  // ignore: avoid_renaming_method_parameters
  Future<void> removeQueueItem(MediaItem mediaItem_) async {
    if (shuffleModeEnabled) {
      final id = mediaItem_.id;
      final itemIndex = shuffledQueue.indexOf(id);
      if (currentShuffleIndex > itemIndex) {
        currentShuffleIndex -= 1;
      }
      shuffledQueue.remove(id);
    }

    final currentQueue = queue.value;
    final currentSong = mediaItem.value;
    final itemIndex = currentQueue.indexOf(mediaItem_);
    if (currentIndex > itemIndex) {
      currentIndex -= 1;
    }
    currentQueue.remove(mediaItem_);
    queue.add(currentQueue);
    mediaItem.add(currentSong);
  }

  @override
  Future<void> play() async {
    if (currentSongUrl == null ||
        (GetPlatform.isDesktop && (_player.duration == null || _player.duration?.inMilliseconds == 0))) {
      await customAction('playByIndex', {'index': currentIndex});
      return;
    }
    // Workaround for network error pause in case of PlayingUsingLockCachingSource
    // if (isPlayingUsingLockCachingSource && networkErrorPause) {
    //   await _player.play();
    //   Future.delayed(const Duration(seconds: 2)).then((value) {
    //     if (_player.playing) {
    //       networkErrorPause = false;
    //     }
    //   });
    //   await _player.play();
    //   return;
    // }
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    await customAction('playByIndex', {'index': index});
  }

  int _getNextSongIndex() {
    if (shuffleModeEnabled) {
      if (currentShuffleIndex + 1 >= shuffledQueue.length) {
        shuffledQueue.shuffle();
        currentShuffleIndex = 0;
      } else {
        currentShuffleIndex += 1;
      }
      return queue.value.indexWhere((item) => item.id == shuffledQueue[currentShuffleIndex]);
    }

    if (queue.value.length > currentIndex + 1) {
      return currentIndex + 1;
    } else if (queueLoopModeEnabled) {
      return 0;
    } else {
      return currentIndex;
    }
  }

  int _getPrevSongIndex() {
    if (shuffleModeEnabled) {
      if (currentShuffleIndex - 1 < 0) {
        shuffledQueue.shuffle();
        currentShuffleIndex = shuffledQueue.length - 1;
      } else {
        currentShuffleIndex -= 1;
      }
      return queue.value.indexWhere((item) => item.id == shuffledQueue[currentShuffleIndex]);
    }

    if (currentIndex - 1 >= 0) {
      return currentIndex - 1;
    } else {
      return currentIndex;
    }
  }

  @override
  Future<void> skipToNext() async {
    final index = _getNextSongIndex();
    if (index != currentIndex) {
      _player.seek(Duration.zero);
      await customAction('playByIndex', {'index': index});
    } else {
      _player.seek(Duration.zero);
      _player.pause();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inMilliseconds > 5000) {
      _player.seek(Duration.zero);
      return;
    }
    _player.seek(Duration.zero);
    final index = _getPrevSongIndex();
    if (index != currentIndex) {
      await customAction('playByIndex', {'index': index});
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (repeatMode == AudioServiceRepeatMode.none) {
      loopModeEnabled = false;
    } else {
      loopModeEnabled = true;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      shuffleModeEnabled = false;
      shuffledQueue.clear();
    } else {
      _shuffleCmd(currentIndex);
      shuffleModeEnabled = true;
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    } else if (name == 'playByIndex') {
      final songIndex = extras!['index'];
      currentIndex = songIndex;
      final isNewUrlReq = extras['newUrl'] ?? false;
      final currentSong = queue.value[currentIndex];
      final futureStreamInfo = checkNGetUrl(currentSong.id, generateNewUrl: isNewUrlReq);
      final bool restoreSession = extras['restoreSession'] ?? false;
      isSongLoading = true;
      if (_playList.children.isNotEmpty) {
        await _playList.clear();
      }

      mediaItem.add(currentSong);
      final streamInfo = await futureStreamInfo;
      if (songIndex != currentIndex) {
        return;
      } else if (streamInfo == null || !streamInfo[0]) {
        currentSongUrl = null;
        isSongLoading = false;
        Get.find<PlayerController>().notifyPlayError(streamInfo == null);
        playbackState.add(playbackState.value.copyWith(processingState: AudioProcessingState.error));
        return;
      }
      currentSongUrl = currentSong.extras!['url'] = streamInfo[1]['url'];
      playbackState.add(playbackState.value.copyWith(queueIndex: currentIndex));
      await _playList.add(_createAudioSource(currentSong));
      isSongLoading = false;

      if (loudnessNormalizationEnabled && GetPlatform.isAndroid) {
        _normalizeVolume(streamInfo[1]['loudnessDb'] ?? 0);
      }

      if (restoreSession) {
        if (!GetPlatform.isDesktop) {
          final position = extras['position'];
          await _player.load();
          await _player.seek(
            Duration(
              milliseconds: position,
            ),
          );
          await _player.seek(
            Duration(
              milliseconds: position,
            ),
          );
        }
      } else {
        await _player.play();
      }
    } else if (name == 'checkWithCacheDb' && isPlayingUsingLockCachingSource) {
      final song = extras!['mediaItem'] as MediaItem;
      final songsCacheBox = Hive.box('SongsCache');
      if (!songsCacheBox.containsKey(song.id) && await File('$_cacheDir/cachedSongs/${song.id}.mp3').exists()) {
        song.extras!['url'] = currentSongUrl;
        song.extras!['date'] = DateTime.now().millisecondsSinceEpoch;
        final dbStreamData = Hive.box('SongsUrlCache').get(song.id);
        final jsonData = MediaItemBuilder.toJson(song);
        jsonData['duration'] = _player.duration!.inSeconds;
        // playbility status and info
        jsonData['streamInfo'] =
            dbStreamData != null ? [true, dbStreamData[Hive.box('AppPrefs').get('streamingQuality') + 1]] : null;
        songsCacheBox.put(song.id, jsonData);
        if (!librarySongsController.isClosed) {
          librarySongsController.librarySongsList.value = librarySongsController.librarySongsList.toList() + [song];
        }
      }
    } else if (name == 'setSourceNPlay') {
      final currMed = extras!['mediaItem'] as MediaItem;
      final futureStreamInfo = checkNGetUrl(currMed.id);
      isSongLoading = true;
      currentIndex = 0;
      await _playList.clear();
      mediaItem.add(currMed);
      queue.add([currMed]);
      final streamInfo = await futureStreamInfo;
      if (streamInfo == null || !streamInfo[0]) {
        currentSongUrl = null;
        isSongLoading = false;
        Get.find<PlayerController>().notifyPlayError(streamInfo == null);
        playbackState.add(playbackState.value.copyWith(processingState: AudioProcessingState.error));
        return;
      }
      currentSongUrl = currMed.extras!['url'] = streamInfo[1]['url'];

      await _playList.add(_createAudioSource(currMed));
      isSongLoading = false;

      // Normalize audio
      if (loudnessNormalizationEnabled && GetPlatform.isAndroid) {
        _normalizeVolume(streamInfo[1]['loudnessDb'] ?? 0);
      }

      await _player.play();
    } else if (name == 'toggleSkipSilence') {
      final enable = extras!['enable'] as bool;
      await _player.setSkipSilenceEnabled(enable);
    } else if (name == 'toggleLoudnessNormalization') {
      loudnessNormalizationEnabled = extras!['enable'] as bool;
      if (!loudnessNormalizationEnabled) {
        _player.setVolume(1);
        return;
      }

      if (loudnessNormalizationEnabled) {
        try {
          final currentSongId = queue.value[currentIndex].id;
          final songQualityIndex = Hive.box('AppPrefs').get('streamingQuality');
          if (Hive.box('SongsUrlCache').containsKey(currentSongId)) {
            _normalizeVolume(Hive.box('SongsUrlCache').get(currentSongId)[songQualityIndex + 1]['loudnessDb']);
            return;
          }

          if (Hive.box('SongDownloads').containsKey(currentSongId)) {
            final streamInfo = Hive.box('SongDownloads').get(currentSongId)['streamInfo'];

            _normalizeVolume(streamInfo == null ? 0 : streamInfo[1]['loudnessDb']);
          }
        } catch (e) {
          printERROR(e);
        }
      }
    } else if (name == 'shuffleQueue') {
      final currentQueue = queue.value;
      final currentItem = currentQueue[currentIndex];
      currentQueue.remove(currentItem);
      currentQueue.shuffle();
      currentQueue.insert(0, currentItem);
      queue.add(currentQueue);
      mediaItem.add(currentItem);
      currentIndex = 0;
    } else if (name == 'reorderQueue') {
      final oldIndex = extras!['oldIndex'];
      int newIndex = extras['newIndex'];

      if (oldIndex < newIndex) {
        newIndex--;
      }

      final currentQueue = queue.value;
      final currentItem = currentQueue[currentIndex];
      final item = currentQueue.removeAt(
        oldIndex,
      );
      currentQueue.insert(newIndex, item);
      currentIndex = currentQueue.indexOf(currentItem);
      queue.add(currentQueue);
      mediaItem.add(currentItem);
    } else if (name == 'addPlayNextItem') {
      final song = extras!['mediaItem'] as MediaItem;
      final currentQueue = queue.value;
      currentQueue.insert(currentIndex + 1, song);
      queue.add(currentQueue);
      if (shuffleModeEnabled) {
        shuffledQueue.insert(currentShuffleIndex + 1, song.id);
      }
    } else if (name == 'openEqualizer') {
      await deviceEqualizer?.open(_player.androidAudioSessionId!);
    } else if (name == 'saveSession') {
      await saveSessionData();
    } else if (name == 'setVolume') {
      _player.setVolume(extras!['value'] / 100);
    } else if (name == 'shuffleCmd') {
      final songIndex = extras!['index'];
      _shuffleCmd(songIndex);
    } else if (name == 'upadateMediaItemInAudioService') {
      //added to update media item from player controller
      final songIndex = extras!['index'];
      currentIndex = songIndex;
      mediaItem.add(queue.value[currentIndex]);
    } else if (name == 'toggleQueueLoopMode') {
      queueLoopModeEnabled = extras!['enable'];
    }
  }

  void _shuffleCmd(int index) {
    final queueIds = queue.value.toList().map((item) => item.id).toList();
    final currentSongId = queueIds.removeAt(index);
    queueIds.shuffle();
    queueIds.insert(0, currentSongId);
    shuffledQueue.replaceRange(0, shuffledQueue.length, queueIds);
    currentShuffleIndex = 0;
  }

  void _normalizeVolume(double currentLoudnessDb) {
    var loudnessDifference = -10 - currentLoudnessDb;

    // Converted loudness difference to a volume multiplier
    // We use a factor to convert dB difference to a linear scale
    // 10^(difference / 20) converts dB difference to a linear volume factor
    final volumeAdjustment = pow(10.0, loudnessDifference / 20.0);
    printINFO('loudness:$currentLoudnessDb Normalized volume: $volumeAdjustment');
    _player.setVolume(volumeAdjustment.toDouble().clamp(0, 1.0));
  }

  Future<void> saveSessionData() async {
    if (Get.find<SettingsScreenController>().restorePlaybackSession.isFalse) {
      return;
    }
    final currQueue = queue.value;
    if (currQueue.isNotEmpty) {
      final queueData = currQueue.map(MediaItemBuilder.toJson).toList();
      final currIndex = currentIndex ?? 0;
      final position = _player.position.inMilliseconds;
      final prevSessionData = await Hive.openBox('prevSessionData');
      await prevSessionData.clear();
      await prevSessionData.putAll({'queue': queueData, 'position': position, 'index': currIndex});
      await prevSessionData.close();
      printINFO('Saved session data');
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    final stopForegroundService = Get.find<SettingsScreenController>().stopPlyabackOnSwipeAway.value;
    if (stopForegroundService) {
      await Get.find<HomeScreenController>().cachedHomeScreenData();
      await saveSessionData();
      await stop();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

// Work around used [useNewInstanceOfExplode = false] to Fix Connection closed before full header was received issue
  Future<List<dynamic>?> checkNGetUrl(String songId,
      {bool generateNewUrl = false, bool offlineReplacementUrl = false}) async {
    printINFO('Requested id : $songId');
    final songDownloadsBox = Hive.box('SongDownloads');
    if (!offlineReplacementUrl && (await Hive.openBox('SongsCache')).containsKey(songId)) {
      printINFO('Got Song from cachedbox ($songId)');
      // if contains stream Info
      final streamInfo = Hive.box('SongsCache').get(songId)['streamInfo'];
      if (streamInfo != null) {
        streamInfo[1]['url'] = 'file://$_cacheDir/cachedSongs/$songId.mp3';
        return streamInfo;
      }

      return [
        true,
        {'url': 'file://$_cacheDir/cachedSongs/$songId.mp3'}
      ];
    } else if (!offlineReplacementUrl && songDownloadsBox.containsKey(songId)) {
      final song = songDownloadsBox.get(songId);
      final streamInfo = song['streamInfo'] ?? [];
      final path = song['url'];
      if (streamInfo.isEmpty) {
        streamInfo.addAll([
          true,
          {'url': path}
        ]);
      }

      if (path.contains('${Get.find<SettingsScreenController>().supportDirPath}/Music')) {
        return streamInfo;
      }
      //check file access and if file exist in storage
      final status = await PermissionService.getExtStoragePermission();
      if (status && await File(path).exists()) {
        return streamInfo;
      }
      //in case file doesnot found in storage, song will be played online
      return checkNGetUrl(songId, offlineReplacementUrl: true);
    } else {
      //check if song stream url is cached and allocate url accordingly
      final songsUrlCacheBox = Hive.box('SongsUrlCache');
      final qualityIndex = Hive.box('AppPrefs').get('streamingQuality');
      dynamic streamInfo;
      if (songsUrlCacheBox.containsKey(songId) && !generateNewUrl) {
        streamInfo = songsUrlCacheBox.get(songId);

        if (streamInfo.length == 3 &&
            streamInfo[0] &&
            !isExpired(url: songsUrlCacheBox.get(songId)[qualityIndex + 1]['url'])) {
          printINFO('Got URLLLLLL cachedbox ($songId)');
        } else {
          streamInfo = await Isolate.run(() => getStreamInfo(songId));
          if (streamInfo != null) songsUrlCacheBox.put(songId, streamInfo);
        }
      } else {
        streamInfo = await Isolate.run(() => getStreamInfo(songId)); //(await musicServices.getSongStreamUrl(songId));
        if (streamInfo != null) {
          songsUrlCacheBox.put(songId, streamInfo);
          printERROR('Url cached in Box for songId $songId');
        }
      }

      /// [it will return [playbility status, streamInfo in map as per quality selected]
      return streamInfo != null ? [streamInfo[0], streamInfo[qualityIndex + 1]] : null;
    }
  }
}

class UrlError extends Error {
  String message() => 'Unable to fetch url';
}
