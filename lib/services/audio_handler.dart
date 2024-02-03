import 'dart:io';
import 'dart:isolate';

import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_service/audio_service.dart';

import '/services/background_task.dart';
import '/services/permission_service.dart';
import '../utils/helper.dart';
import '/models/media_Item_builder.dart';
import '/services/utils.dart';
import '../ui/screens/Settings/settings_screen_controller.dart';
import '../ui/screens/Library/library_controller.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationIcon: 'mipmap/ic_launcher_monochrome',
      androidNotificationChannelId: 'com.mycompany.myapp.audio',
      androidNotificationChannelName: 'Harmony Music Notification',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with GetxServiceMixin {
  // ignore: prefer_typing_uninitialized_variables
  late final _cacheDir;
  late Player _player;
  // ignore: prefer_typing_uninitialized_variables
  var currentIndex;
  late String? currentSongUrl;
  bool isPlayingUsingLockCachingSource = false;
  bool loopModeEnabled = false;
  var networkErrorPause = false;
  bool isSongLoading = true;

  LibrarySongsController librarySongsController =
      Get.find<LibrarySongsController>();

  MyAudioHandler() {
    _player = Player(
        configuration: const PlayerConfiguration(title: "Harmony Music"));
    _createCacheDir();
    _notifyAudioHandlerAboutPlaybackEvents();
    //_player.setSkipSilenceEnabled(Hive.box("appPrefs").get("skipSilenceEnabled"));
    loopModeEnabled = Hive.box("appPrefs").get("isLoopModeEnabled") ?? false;
  }

  Future<void> _createCacheDir() async {
    _cacheDir = (await getTemporaryDirectory()).path;
    if (!Directory("$_cacheDir/cachedSongs/").existsSync()) {
      Directory("$_cacheDir/cachedSongs/").createSync(recursive: true);
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.stream.duration.listen((Duration dur) {
      printINFO(dur.inSeconds);
      var index = currentIndex;
      final newQueue = queue.value;
      final oldMediaItem = newQueue[index];
      if (dur.inSeconds != 0) {
        final newMediaItem = oldMediaItem.copyWith(duration: dur);
        newQueue[index] = newMediaItem;
        queue.add(newQueue);
        mediaItem.add(newMediaItem);
      }
    });

    _player.stream.buffer.listen((Duration bufferedPosition) {
      playbackState.add(
          playbackState.value.copyWith(bufferedPosition: bufferedPosition));
    });

    _player.stream.completed.listen((bool isCompleted) {
      if (isCompleted) {
        playbackState.add(playbackState.value
            .copyWith(processingState: AudioProcessingState.completed));
      }
    });

    _player.stream.playing.listen(
      (bool playing) {
        playbackState.add(playbackState.value.copyWith(
          playing: playing,
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
          },
          androidCompactActionIndices: const [0, 1, 2],
        ));
      },
    );

    final playerDurationOffset = GetPlatform.isWindows
        ? 200
        : GetPlatform.isLinux
            ? 700
            : 0;
    _player.stream.position.listen((Duration position) async {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
      if (_player.state.duration.inSeconds != 0) {
        if (position.inMilliseconds >=
            (_player.state.duration.inMilliseconds - playerDurationOffset)) {
          await _triggerNext();
        }
      }
    });
  }

  Future<void> _triggerNext() async {
    if (loopModeEnabled) {
      await _player.seek(Duration.zero);
      if (!_player.state.playing) {
        _player.play();
      }
      return;
    }
    skipToNext();
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // notify system
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    final newQueue = this.queue.value
      ..replaceRange(0, this.queue.value.length, queue);
    this.queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // notify system
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    // notify system
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  // ignore: avoid_renaming_method_parameters
  Future<void> removeQueueItem(MediaItem mediaItem_) async {
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
    if (currentSongUrl == null) {
      await customAction("playByIndex", {'index': currentIndex});
      return;
    }
    // Workaround for network error pause in case of PlayingUsingLockCachingSource
    if (isPlayingUsingLockCachingSource && networkErrorPause) {
      await _player.play();
      Future.delayed(const Duration(seconds: 2)).then((value) {
        if (_player.state.playing) {
          networkErrorPause = false;
        }
      });
      await _player.play();
      return;
    }
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    await customAction("playByIndex", {'index': index});
  }

  @override
  Future<void> skipToNext() async {
    if (queue.value.length > currentIndex + 1) {
      _player.seek(Duration.zero);
      _player.pause();
      await customAction("playByIndex", {'index': currentIndex + 1});
    } else {
      _player.seek(Duration.zero);
      _player.pause();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.state.position.inMilliseconds > 5000) {
      _player.seek(Duration.zero);
      return;
    }
    _player.seek(Duration.zero);
    if (currentIndex - 1 >= 0) {
      _player.pause();
      await customAction("playByIndex", {'index': currentIndex - 1});
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
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    } else if (name == 'playByIndex') {
      currentIndex = extras!['index'];
      playbackState.add(
        playbackState.value.copyWith(
          bufferedPosition: Duration.zero,
          processingState: AudioProcessingState.loading,
          queueIndex: currentIndex,
        ),
      );
      final isNewUrlReq = extras['newUrl'] ?? false;
      final currentSong = queue.value[currentIndex];
      final url =
          await checkNGetUrl(currentSong.id, generateNewUrl: isNewUrlReq);
      mediaItem.add(currentSong);
      currentSongUrl = url;
      if (url == null) {
        return;
      }
      currentSong.extras!['url'] = url;
      playbackState.add(playbackState.value.copyWith(queueIndex: currentIndex));
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.ready,
        ),
      );
      _player.open(Media(url));
      if (currentIndex == 0) {
        cacheNextSongUrl(offset: 1);
      }
      cacheNextSongUrl();
    } else if (name == "checkWithCacheDb" && isPlayingUsingLockCachingSource) {
      final song = extras!['mediaItem'] as MediaItem;
      final songsCacheBox = Hive.box("SongsCache");
      if (!songsCacheBox.containsKey(song.id) &&
          await File("$_cacheDir/cachedSongs/${song.id}.mp3").exists()) {
        song.extras!['url'] = currentSongUrl;
        song.extras!['date'] = DateTime.now().millisecondsSinceEpoch;
        final jsonData = MediaItemBuilder.toJson(song);
        jsonData['duration'] = _player.state.duration.inSeconds;
        songsCacheBox.put(song.id, jsonData);
        if (!librarySongsController.isClosed) {
          librarySongsController.librarySongsList.value =
              librarySongsController.librarySongsList.toList() + [song];
        }
      }
    } else if (name == 'setSourceNPlay') {
      _player.pause();
      playbackState.add(playbackState.value.copyWith(
        bufferedPosition: Duration.zero,
        processingState: AudioProcessingState.loading,
        queueIndex: 0,
      ));
      final currMed = (extras!['mediaItem'] as MediaItem);
      currentIndex = 0;
      mediaItem.add(currMed);
      queue.add([currMed]);
      final url = (await checkNGetUrl(currMed.id));
      currentSongUrl = url;
      if (url == null) {
        return;
      }
      currentSongUrl = url;
      currMed.extras!['url'] = url;
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.ready,
        ),
      );
      _player.open(Media(url));
      cacheNextSongUrl(offset: 1);
      cacheNextSongUrl(offset: 2);
    } else if (name == 'toggleSkipSilence') {
      final enable = (extras!['enable'] as bool);
      //await _player.setSkipSilenceEnabled(enable);
    } else if (name == "shuffleQueue") {
      final currentQueue = queue.value;
      final currentItem = currentQueue[currentIndex];
      currentQueue.remove(currentItem);
      currentQueue.shuffle();
      currentQueue.insert(0, currentItem);
      queue.add(currentQueue);
      mediaItem.add(currentItem);
      currentIndex = 0;
      cacheNextSongUrl();
    } else if (name == "reorderQueue") {
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
    } else if (name == 'openEqualizer') {
      //await DeviceEqualizer().open();
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    final stopForegroundService =
        Get.find<SettingsScreenController>().stopPlyabackOnSwipeAway.value;
    if (stopForegroundService) {
      await stop();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  Future<void> cacheNextSongUrl({int offset = 2}) async {
    if (queue.value.length > currentIndex + offset) {
      final songId = (queue.value[currentIndex + offset]).id;
      if (isExpired(url: Hive.box("SongsUrlCache").get(songId)?.first) &&
          !(Hive.box("SongDownloads").containsKey(songId)) &&
          !(Hive.box("SongsCache").containsKey(songId))) {
        Future.sync(() => Isolate.run(() => getSongUrlFromExplode(songId))
                .then((value) async {
              if (value != null) {
                await Hive.box("SongsUrlCache").put(songId, value);
                printWarning("Isolate: Next Song Url Cached song Id $songId");
              }
            }));
      }
    }
  }

// Work around used [useNewInstanceOfExplode = false] to Fix Connection closed before full header was received issue
  Future<String?> checkNGetUrl(String songId,
      {bool generateNewUrl = false, bool offlineReplacementUrl = false}) async {
    printINFO("Requested id : $songId");
    final songDownloadsBox = Hive.box("SongDownloads");
    if (!offlineReplacementUrl &&
        (await Hive.openBox("SongsCache")).containsKey(songId)) {
      printINFO("Got Song from cachedbox ($songId)");
      return "file://$_cacheDir/cachedSongs/$songId.mp3";
    } else if (!offlineReplacementUrl && songDownloadsBox.containsKey(songId)) {
      final path = songDownloadsBox.get(songId)['url'];

      if (path.contains(
          "${Get.find<SettingsScreenController>().supportDirPath}/Music")) {
        return path;
      }
      //check file access and if file exist in storage
      final status = await PermissionService.getExtStoragePermission();
      if (status && await File(path).exists()) {
        return path;
      }
      //in case file doesnot found in storage, song will be played online
      return checkNGetUrl(songId, offlineReplacementUrl: true);
    } else {
      //check if song stream url is cached and allocate url accordingly
      final songsUrlCacheBox = Hive.box("SongsUrlCache");
      final qualityIndex = Hive.box('AppPrefs').get('streamingQuality');
      dynamic url;
      if (songsUrlCacheBox.containsKey(songId) && !generateNewUrl) {
        if (isExpired(url: songsUrlCacheBox.get(songId)[qualityIndex])) {
          url = await Isolate.run(() => getSongUrlFromExplode(songId));
          if (url != null) songsUrlCacheBox.put(songId, url);
        } else {
          url = songsUrlCacheBox.get(songId);
          printINFO("Got URLLLLLL cachedbox ($songId)");
        }
      } else {
        url = await Isolate.run(() => getSongUrlFromExplode(
            songId)); //(await musicServices.getSongStreamUrl(songId));
        if (url != null) {
          songsUrlCacheBox.put(songId, url);
          printERROR("Url cached in Box for songId $songId");
        }
      }

      return url != null ? url[qualityIndex] : null;
    }
  }
}

class UrlError extends Error {
  String message() => 'Unable to fetch url';
}
