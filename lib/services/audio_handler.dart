import 'dart:io';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:device_equalizer/device_equalizer.dart';

import '../utils/helper.dart';
import '/models/media_Item_builder.dart';
import '/services/utils.dart';
import '/ui/screens/settings_screen_controller.dart';
import '../ui/utils/home_library_controller.dart';
import 'music_service.dart';

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
  final _player = AudioPlayer();
  // ignore: prefer_typing_uninitialized_variables
  var currentIndex;
  late String? currentSongUrl;
  bool isPlayingUsingLockCachingSource = false;
  bool loopModeEnabled = false;
  var networkErrorPause = false;

  final _playList = ConcatenatingAudioSource(
    children: [],
  );
  LibrarySongsController librarySongsController =
      Get.find<LibrarySongsController>();

  MyAudioHandler() {
    _createCacheDir();
    _addEmptyList();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenToPlaybackForNextSong();
    _listenForSequenceStateChanges();
    _player
        .setSkipSilenceEnabled(Hive.box("appPrefs").get("skipSilenceEnabled"));
  }

  Future<void> _createCacheDir() async {
    _cacheDir = (await getTemporaryDirectory()).path;
    if (!Directory("$_cacheDir/cachedSongs/").existsSync()) {
      Directory("$_cacheDir/cachedSongs/").createSync(recursive: true);
    }
  }

  void _addEmptyList() {
    try {
      _player.setAudioSource(_playList);
    } catch (r) {
      printERROR(r.toString());
    }
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
        processingState: const {
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
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
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
        final box = Hive.box("songsUrlCache");
        if (box.containsKey(mediaItem.value!.id)) {
          if (isExpired(url: box.get(mediaItem.value!.id)[1])) {
            await _player.stop();
            await customAction("playByIndex", {'index': currentIndex});
            return;
          }
        }
        if (isPlayingUsingLockCachingSource &&
            e.toString().contains("Connection closed while receiving data")) {
          Duration curPos = _player.position;
          await _player.stop();
          await _player.seek(curPos, index: 0);
          await _player.play();
        }

        //Workaround when 403 error encountered
        customAction("playByIndex", {'index': currentIndex, 'newUrl': true})
            .whenComplete(() async {
          await _player.stop();
          if (currentSongUrl == null) {
            networkErrorPause = true;
          } else {
            _player.play();
          }
        });
      }
    });
  }

  void _listenToPlaybackForNextSong() {
    _player.positionStream.listen((value) async {
      if (_player.duration != null &&
          value.inMilliseconds >= _player.duration!.inMilliseconds) {
        await _triggerNext();
      }
    });
  }

  Future<void> _triggerNext() async {
    if (loopModeEnabled) {
     await _player.seek(Duration.zero);
     if(!_player.playing){
      _player.play();
     }
      return;
    }
    skipToNext();
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) async {
      var index = currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
    });
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

  AudioSource _createAudioSource(MediaItem mediaItem) {
    final url = mediaItem.extras!['url'] as String;
    if (url.contains('file') ||
        Get.find<SettingsScreenController>().cacheSongs.isTrue) {
      printINFO("Playing Using LockCaching");
      isPlayingUsingLockCachingSource = true;
      return LockCachingAudioSource(
        Uri.parse(url),
        cacheFile: File("$_cacheDir/cachedSongs/${mediaItem.id}.mp3"),
        tag: mediaItem,
      );
    }

    printINFO("Playing Using AudioSource.uri");
    isPlayingUsingLockCachingSource = false;
    return AudioSource.uri(
      Uri.tryParse(url)!,
      tag: mediaItem,
    );
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
        if (_player.playing) {
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
      await customAction("playByIndex", {'index': currentIndex + 1});
    } else {
      _player.seek(Duration.zero);
      _player.pause();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    _player.seek(Duration.zero);
    if (currentIndex - 1 >= 0) {
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
      if (_playList.children.isNotEmpty) {
        await _playList.clear();
      }
      currentIndex = extras!['index'];
      final isNewUrlReq = extras['newUrl'] ?? false;
      final currentSong = queue.value[currentIndex];
      mediaItem.add(currentSong);
      final url =
          await checkNGetUrl(currentSong.id, generateNewUrl: isNewUrlReq);
      currentSongUrl = url;
      if (url == null) {
        return;
      }
      currentSong.extras!['url'] = url;
      playbackState.add(playbackState.value.copyWith(queueIndex: currentIndex));

      await _playList.add(_createAudioSource(currentSong));

      await _player.play();
      cacheNextSongUrl();
    } else if (name == "checkWithCacheDb" && isPlayingUsingLockCachingSource) {
      final song = extras!['mediaItem'] as MediaItem;
      final songsCacheBox = Hive.box("SongsCache");
      if (!songsCacheBox.containsKey(song.id) &&
          await File("$_cacheDir/cachedSongs/${song.id}.mp3").exists()) {
        song.extras!['url'] = currentSongUrl;
        song.extras!['date'] = DateTime.now().millisecondsSinceEpoch;
        final jsonData = MediaItemBuilder.toJson(song);
        jsonData['duration'] = _player.duration!.inSeconds;
        songsCacheBox.put(song.id, jsonData);
        if (!librarySongsController.isClosed) {
          librarySongsController.cachedSongsList.value =
              librarySongsController.cachedSongsList.toList() + [song];
        }
      }
    } else if (name == 'setSourceNPlay') {
      await _playList.clear();
      final currMed = (extras!['mediaItem'] as MediaItem);
      currentIndex = 0;
      mediaItem.add(currMed);
      queue.add([currMed]);
      final url =
          (await checkNGetUrl(currMed.id, useNewInstanceOfExplode: true));
      currentSongUrl = url;
      if (url == null) {
        return;
      }
      currentSongUrl = url;
      currMed.extras!['url'] = url;
      await _playList.add(_createAudioSource(currMed));
      await _player.play();
      cacheNextSongUrl();
    } else if (name == 'toggleSkipSilence') {
      final enable = (extras!['enable'] as bool);
      await _player.setSkipSilenceEnabled(enable);
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
      await DeviceEqualizer().open(_player.androidAudioSessionId!);
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    final stopForegroundService = Get.find<SettingsScreenController>().stopPlyabackOnSwipeAway.value;
    if (stopForegroundService) {
      await stop();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  Future<void> cacheNextSongUrl() async {
    if (queue.value.length > currentIndex + 1) {
      await checkNGetUrl((queue.value[currentIndex + 1]).id);
      printINFO("Next Song Url Cached");
    }
  }

// Work around used [useNewInstanceOfExplode = false] to Fix Connection closed before full header was received issue
  Future<String?> checkNGetUrl(String songId,
      {bool useNewInstanceOfExplode = false,
      bool generateNewUrl = false}) async {
    final songsCacheBox = await Hive.openBox("SongsCache");
    if (songsCacheBox.containsKey(songId)) {
      printINFO("Got Song from cachedbox ($songId)");
      return "file://$_cacheDir/cachedSongs/$songId.mp3";
    } else {
      //check if song stream url is cached and allocate url accordingly
      final songsUrlCacheBox = Hive.box("SongsUrlCache");
      final qualityIndex = Hive.box('AppPrefs').get('streamingQuality');
      final musicServices = Get.find<MusicServices>();
      final newMusicServicesIns =
          useNewInstanceOfExplode ? MusicServices(false) : null;
      dynamic url;
      if (songsUrlCacheBox.containsKey(songId) && !generateNewUrl) {
        if (isExpired(url: songsUrlCacheBox.get(songId)[qualityIndex])) {
          url = useNewInstanceOfExplode
              ? await newMusicServicesIns!.getSongUri(songId)
              : (await musicServices.getSongUri(songId));
          if (url != null) songsUrlCacheBox.put(songId, url);
        } else {
          url = songsUrlCacheBox.get(songId);
        }
      } else {
        url = useNewInstanceOfExplode
            ? await newMusicServicesIns!.getSongUri(songId)
            : (await musicServices.getSongUri(songId));
        if (url != null) {
          songsUrlCacheBox.put(songId, url);
          printINFO("Url cached in Box for songId $songId");
        }
      }
      if (useNewInstanceOfExplode) {
        newMusicServicesIns!.closeYtClient();
      }
      return url != null ? url[qualityIndex] : null;
    }
  }
}

class UrlError extends Error {
  String message() => 'Unable to fetch url';
}
