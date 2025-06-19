import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/services.dart';


import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_service/audio_service.dart';
// ignore: depend_on_referenced_packages
import 'package:rxdart/rxdart.dart';

import '/models/album.dart';
import '../models/playlist.dart';
import '/services/equalizer.dart';
import '/services/stream_service.dart';
import '/models/hm_streaming_data.dart';
import '/ui/player/player_controller.dart';
import '../ui/screens/Home/home_screen_controller.dart';
import '/services/background_task.dart';
import '/services/permission_service.dart';
import '../utils/helper.dart';
import '/models/media_Item_builder.dart';
import '/services/utils.dart';
import '../ui/screens/Settings/settings_screen_controller.dart';
import '../ui/screens/Library/library_controller.dart';
// ignore: unused_import, implementation_imports, depend_on_referenced_packages
import "package:media_kit/src/player/platform_player.dart" show MPVLogLevel;

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
  late AudioPlayer _player;
  late MediaLibrary _mediaLibrary;
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

  // list of shuffled queue songs ids
  List<String> shuffledQueue = [];

  final _playList =
      ConcatenatingAudioSource(children: [], useLazyPreparation: false);

  MyAudioHandler() {
    if (GetPlatform.isWindows || GetPlatform.isLinux) {
      JustAudioMediaKit.title = 'Harmony music';
      JustAudioMediaKit.protocolWhitelist = const ['http', 'https', 'file'];
    }
    _mediaLibrary = MediaLibrary();
    _player = AudioPlayer(
        audioLoadConfiguration: const AudioLoadConfiguration(
            androidLoadControl: AndroidLoadControl(
      minBufferDuration: Duration(seconds: 50),
      maxBufferDuration: Duration(seconds: 120),
      bufferForPlaybackDuration: Duration(milliseconds: 50),
      bufferForPlaybackAfterRebufferDuration: Duration(seconds: 2),
    )));
    _createCacheDir();
    _addEmptyList();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenToPlaybackForNextSong();
    _listenForSequenceStateChanges();
    final appPrefsBox = Hive.box("appPrefs");
    _player
        .setSkipSilenceEnabled(appPrefsBox.get("skipSilenceEnabled") ?? false);
    loopModeEnabled = appPrefsBox.get("isLoopModeEnabled") ?? false;
    shuffleModeEnabled = appPrefsBox.get("isShuffleModeEnabled") ?? false;
    queueLoopModeEnabled =
        Hive.box("AppPrefs").get("queueLoopModeEnabled") ?? false;
    loudnessNormalizationEnabled =
        appPrefsBox.get("loudnessNormalizationEnabled") ?? false;
    _listenForDurationChanges();
    if (GetPlatform.isAndroid) {
      _listenSessionIdStream();
    }
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

  void _listenSessionIdStream() {
    _player.androidAudioSessionIdStream.listen((int? id) {
      if (id != null) {
        EqualizerService.initAudioEffect(id);
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
        shuffleMode: (shuffleModeEnabled)
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
        Duration curPos = _player.position;
        await _player.stop();

        if (isPlayingUsingLockCachingSource &&
            e.toString().contains("Connection closed while receiving data")) {
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
        customAction("playByIndex", {'index': currentIndex, 'newUrl': true});
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
        if (value.inMilliseconds >=
            (_player.duration!.inMilliseconds - playerDurationOffset)) {
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
      final notPlayedshuffledQueue = shuffledQueue.isNotEmpty
          ? shuffledQueue.toList().sublist(currentShuffleIndex + 1)
          : shuffledQueue;
      notPlayedshuffledQueue.addAll(mediaItemsIds);
      notPlayedshuffledQueue.shuffle();
      shuffledQueue.replaceRange(
          currentShuffleIndex, shuffledQueue.length, notPlayedshuffledQueue);
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    final newQueue = this.queue.value
      ..replaceRange(0, this.queue.value.length, queue);
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
    if (url.contains('/cache') ||
        (Get.find<SettingsScreenController>().cacheSongs.isTrue &&
            url.contains("http"))) {
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
        (GetPlatform.isDesktop &&
            (_player.duration == null ||
                _player.duration?.inMilliseconds == 0))) {
      await customAction("playByIndex", {'index': currentIndex});
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
    await customAction("playByIndex", {'index': index});
  }

  int _getNextSongIndex() {
    if (shuffleModeEnabled) {
      if (currentShuffleIndex + 1 >= shuffledQueue.length) {
        shuffledQueue.shuffle();
        currentShuffleIndex = 0;
      } else {
        currentShuffleIndex += 1;
      }
      return queue.value
          .indexWhere((item) => item.id == shuffledQueue[currentShuffleIndex]);
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
      return queue.value
          .indexWhere((item) => item.id == shuffledQueue[currentShuffleIndex]);
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
      if (_player.position != Duration.zero) _player.seek(Duration.zero);
      await customAction("playByIndex", {'index': index});
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
      await customAction("playByIndex", {'index': index});
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
    switch (name) {

      case 'dispose':
        await _player.dispose();
        super.stop();
        break;

      case 'playByIndex':
        final songIndex = extras!['index'];
        currentIndex = songIndex;
        final isNewUrlReq = extras['newUrl'] ?? false;
        final currentSong = queue.value[currentIndex];
        final futureStreamInfo =
            checkNGetUrl(currentSong.id, generateNewUrl: isNewUrlReq);
        final bool restoreSession = extras['restoreSession'] ?? false;
        isSongLoading = true;
        playbackState.add(playbackState.value
            .copyWith(processingState: AudioProcessingState.loading));
        if (_playList.children.isNotEmpty) {
          await _playList.clear();
        }

        mediaItem.add(currentSong);
        final streamInfo = await futureStreamInfo;
        if (songIndex != currentIndex) {
          return;
        } else if (!streamInfo.playable) {
          currentSongUrl = null;
          isSongLoading = false;
          Get.find<PlayerController>().notifyPlayError(streamInfo.statusMSG);
          playbackState.add(playbackState.value.copyWith(
              processingState: AudioProcessingState.error,
              errorCode: 404,
              errorMessage: streamInfo.statusMSG));
          return;
        }
        currentSongUrl = currentSong.extras!['url'] = streamInfo.audio!.url;
        playbackState
            .add(playbackState.value.copyWith(queueIndex: currentIndex));
        await _playList.add(_createAudioSource(currentSong));

        isSongLoading = false;
        if (loudnessNormalizationEnabled && GetPlatform.isAndroid) {
          _normalizeVolume(streamInfo.audio!.loudnessDb);
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
        break;

      case 'checkWithCacheDb':
        if (isPlayingUsingLockCachingSource) {
          final song = extras!['mediaItem'] as MediaItem;
          final songsCacheBox = Hive.box("SongsCache");
          if (!songsCacheBox.containsKey(song.id) &&
              await File("$_cacheDir/cachedSongs/${song.id}.mp3").exists()) {
            song.extras!['url'] = currentSongUrl;
            song.extras!['date'] = DateTime.now().millisecondsSinceEpoch;
            final dbStreamData = Hive.box("SongsUrlCache").get(song.id);
            final jsonData = MediaItemBuilder.toJson(song);
            jsonData['duration'] = _player.duration!.inSeconds;
            // playbility status and info
            jsonData['streamInfo'] = dbStreamData != null
                ? [
                    true,
                    dbStreamData[
                        Hive.box('AppPrefs').get('streamingQuality') == 0
                            ? 'lowQualityAudio'
                            : "highQualityAudio"]
                  ]
                : null;
            songsCacheBox.put(song.id, jsonData);
            LibrarySongsController librarySongsController =
                Get.find<LibrarySongsController>();
            if (!librarySongsController.isClosed) {
              librarySongsController.librarySongsList.value =
                  librarySongsController.librarySongsList.toList() + [song];
            }
          }
        }
        break;

      case 'setSourceNPlay':
        final currMed = (extras!['mediaItem'] as MediaItem);
        final futureStreamInfo = checkNGetUrl(currMed.id);
        isSongLoading = true;
        currentIndex = 0;
        await _playList.clear();
        mediaItem.add(currMed);
        queue.add([currMed]);
        final streamInfo = (await futureStreamInfo);
        if (!streamInfo.playable) {
          currentSongUrl = null;
          isSongLoading = false;
          Get.find<PlayerController>().notifyPlayError(streamInfo.statusMSG);
          playbackState.add(playbackState.value
              .copyWith(processingState: AudioProcessingState.error));
          return;
        }
        currentSongUrl = currMed.extras!['url'] = streamInfo.audio!.url;

        await _playList.add(_createAudioSource(currMed));
        isSongLoading = false;

        // Normalize audio
        if (loudnessNormalizationEnabled && GetPlatform.isAndroid) {
          _normalizeVolume(streamInfo.audio!.loudnessDb);
        }

        await _player.play();
        break;

      case 'toggleSkipSilence':
        final enable = (extras!['enable'] as bool);
        await _player.setSkipSilenceEnabled(enable);
        break;

      case 'toggleLoudnessNormalization':
        loudnessNormalizationEnabled = (extras!['enable'] as bool);
        if (!loudnessNormalizationEnabled) {
          _player.setVolume(1.0);
          return;
        }

        if (loudnessNormalizationEnabled) {
          try {
            final currentSongId = (queue.value[currentIndex]).id;
            if (Hive.box("SongsUrlCache").containsKey(currentSongId)) {
              final songJson = Hive.box("SongsUrlCache").get(currentSongId);
              _normalizeVolume((songJson)["highQualityAudio"]["loudnessDb"]);
              return;
            }

            if (Hive.box("SongDownloads").containsKey(currentSongId)) {
              final streamInfo =
                  (Hive.box("SongDownloads").get(currentSongId))["streamInfo"];

              _normalizeVolume(
                  streamInfo == null ? 0 : streamInfo[1]["loudnessDb"]);
            }
          } catch (e) {
            printERROR(e);
          }
        }
        break;

      case 'shuffleQueue':
        final currentQueue = queue.value;
        final currentItem = currentQueue[currentIndex];
        currentQueue.remove(currentItem);
        currentQueue.shuffle();
        currentQueue.insert(0, currentItem);
        queue.add(currentQueue);
        mediaItem.add(currentItem);
        currentIndex = 0;
        break;

      case 'reorderQueue':
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
        break;

      case 'addPlayNextItem':
        final song = extras!['mediaItem'] as MediaItem;
        final currentQueue = queue.value;
        currentQueue.insert(currentIndex + 1, song);
        queue.add(currentQueue);
        if (shuffleModeEnabled) {
          shuffledQueue.insert(currentShuffleIndex + 1, song.id);
        }
        break;

      case 'openEqualizer':
        EqualizerService.openEqualizer(_player.androidAudioSessionId!);
        break;

      case 'saveSession':
        await saveSessionData();
        break;

      case 'setVolume':
        _player.setVolume(extras!['value'] / 100);
        break;

      case 'shuffleCmd':
        final songIndex = extras!['index'];
        _shuffleCmd(songIndex);
        break;

      case 'upadateMediaItemInAudioService':
        //added to update media item from player controller
        final songIndex = extras!['index'];
        currentIndex = songIndex;
        mediaItem.add(queue.value[currentIndex]);
        break;

      case 'toggleQueueLoopMode':
        queueLoopModeEnabled = extras!['enable'];
        break;

      case 'clearQueue':
        customAction("reorderQueue", {'oldIndex': currentIndex, 'newIndex': 0});
        final newQueue = queue.value;
        newQueue.removeRange(1, newQueue.length);
        queue.add(newQueue);
        if (shuffleModeEnabled) {
          shuffledQueue.clear();
          shuffledQueue.add(newQueue[0].id);
          currentShuffleIndex = 0;
        }
        break;
      default:
        break;
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
    double loudnessDifference = -5 - currentLoudnessDb;

    // Converted loudness difference to a volume multiplier
    // We use a factor to convert dB difference to a linear scale
    // 10^(difference / 20) converts dB difference to a linear volume factor
    final volumeAdjustment = pow(10.0, loudnessDifference / 20.0);
    printINFO(
        "loudness:$currentLoudnessDb Normalized volume: $volumeAdjustment");
    _player.setVolume(volumeAdjustment.toDouble().clamp(0, 1.0));
  }

  Future<void> saveSessionData() async {
    if (Get.find<SettingsScreenController>().restorePlaybackSession.isFalse) {
      return;
    }
    final currQueue = queue.value;
    if (currQueue.isNotEmpty) {
      final queueData =
          currQueue.map((e) => MediaItemBuilder.toJson(e)).toList();
      final currIndex = currentIndex ?? 0;
      final position = _player.position.inMilliseconds;
      final prevSessionData = await Hive.openBox("prevSessionData");
      await prevSessionData.clear();
      await prevSessionData.putAll(
          {"queue": queueData, "position": position, "index": currIndex});
      await prevSessionData.close();
      printINFO("Saved session data");
    }
  }

  /// Android Auto
  @override
  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    return _mediaLibrary.getByRootId(parentMediaId);
  }

  @override
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
    return Stream.fromFuture(
            _mediaLibrary.getByRootId(parentMediaId).then((items) => items))
        .map((_) => <String, dynamic>{})
        .shareValue();
  }

  // only for Android Auto
  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    customEvent.add({
      'eventType': 'playFromMediaId',
      'songId': mediaId,
      'libraryId': extras!['libraryId'],
    });
  }

  @override
  Future<void> onTaskRemoved() async {
    final stopForegroundService =
        Get.find<SettingsScreenController>().stopPlyabackOnSwipeAway.value;
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
  Future<HMStreamingData> checkNGetUrl(String songId,
      {bool generateNewUrl = false, bool offlineReplacementUrl = false}) async {
    printINFO("Requested id : $songId");
    final songDownloadsBox = Hive.box("SongDownloads");
    if (!offlineReplacementUrl &&
        (await Hive.openBox("SongsCache")).containsKey(songId)) {
      printINFO("Got Song from cachedbox ($songId)");
      // if contains stream Info
      final streamInfo = Hive.box("SongsCache").get(songId)["streamInfo"];
      Audio? cacheAudioPlaceholder;
      if (streamInfo != null && streamInfo.isNotEmpty) {
        streamInfo[1]['url'] = "file://$_cacheDir/cachedSongs/$songId.mp3";
        cacheAudioPlaceholder = Audio.fromJson(streamInfo[1]);
      } else {
        cacheAudioPlaceholder = Audio(
            audioCodec: Codec.mp4a,
            bitrate: 0,
            loudnessDb: 0,
            duration: 0,
            size: 0,
            url: "file://$_cacheDir/cachedSongs/$songId.mp3",
            itag: 0);
      }

      return HMStreamingData(
          playable: true,
          statusMSG: "OK",
          lowQualityAudio: cacheAudioPlaceholder,
          highQualityAudio: cacheAudioPlaceholder);
    } else if (!offlineReplacementUrl && songDownloadsBox.containsKey(songId)) {
      final song = songDownloadsBox.get(songId);
      final streamInfoJson = song["streamInfo"];
      Audio? audio;
      final path = song['url'];
      if (streamInfoJson != null && streamInfoJson.isNotEmpty) {
        audio = Audio.fromJson(streamInfoJson[1]);
      } else {
        audio = Audio(
            itag: 140,
            audioCodec: Codec.mp4a,
            bitrate: 0,
            duration: 0,
            loudnessDb: 0,
            url: path,
            size: 0);
      }

      final streamInfo = HMStreamingData(
          playable: true,
          statusMSG: "OK",
          highQualityAudio: audio,
          lowQualityAudio: audio);

      if (path.contains(
          "${Get.find<SettingsScreenController>().supportDirPath}/Music")) {
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
      final songsUrlCacheBox = Hive.box("SongsUrlCache");
      final qualityIndex = Hive.box('AppPrefs').get('streamingQuality') ?? 1;
      HMStreamingData? streamInfo;
      if (songsUrlCacheBox.containsKey(songId) && !generateNewUrl) {
        final streamInfoJson = songsUrlCacheBox.get(songId);
        if (streamInfoJson.runtimeType.toString().contains("Map") &&
            !isExpired(url: (streamInfoJson['lowQualityAudio']['url']))) {
          printINFO("Got cached Url ($songId)");
          streamInfo = HMStreamingData.fromJson(streamInfoJson);
        }
      }

      if (streamInfo == null) {
        final token = RootIsolateToken.instance;
        final streamInfoJson =
            await Isolate.run(() => getStreamInfo(songId, token));
        streamInfo = HMStreamingData.fromJson(streamInfoJson);
        if (streamInfo.playable) songsUrlCacheBox.put(songId, streamInfoJson);
      }

      streamInfo.setQualityIndex(qualityIndex as int);
      return streamInfo;
    }
  }
}

class UrlError extends Error {
  String message() => 'Unable to fetch url';
}


// for Android Auto
class MediaLibrary {
  static const albumsRootId = 'albums';
  static const songsRootId = 'songs';
  static const favoritesRootId = "LIBFAV";
  static const playlistsRootId = 'playlists';

  Future<List<MediaItem>> getByRootId(String id) async {
    switch (id) {
      case AudioService.browsableRootId:
        return Future.value(getRoot());
      case songsRootId:
        return getLibSongs("SongDownloads");
      case favoritesRootId:
        return getLibSongs("LIBFAV");
      case albumsRootId:
        return getAlbums();
      case playlistsRootId:
        return getPlaylists();
      case AudioService.recentRootId:
        return getLibSongs("LIBRP");
      default:
        return getLibSongs(id);
    }
  }

  List<MediaItem> getRoot() {
    return [
      MediaItem(
        id: songsRootId,
        title: "songs".tr,
        playable: false,
      ),
      MediaItem(
        id: favoritesRootId,
        title: "favorites".tr,
        playable: false,
      ),
      MediaItem(
        id: albumsRootId,
        title: "albums".tr,
        playable: false,
      ),
      MediaItem(
        id: playlistsRootId,
        title: "playlists".tr,
        playable: false,
      ),
    ];
  }

  Future<List<MediaItem>> getAlbums() async {
    final box = await Hive.openBox("LibraryAlbums");
    final albums =
        box.values.map((item) => Album.fromJson(item).toMediaItem()).toList();
    await box.close();
    return albums;
  }

  Future<List<MediaItem>> getPlaylists() async {
    final box = await Hive.openBox("LibraryPlaylists");
    final playlists = [
      ...LibraryPlaylistsController.initPlst.map((e) => e.toMediaItem()),
      ...(box.values
          .map((item) => Playlist.fromJson(item).toMediaItem())
          .toList())
    ];
    await box.close();
    return playlists;
  }

  Future<List<MediaItem>> getLibSongs(String libId) async {
    Box<dynamic> box;
    try {
      box = await Hive.openBox(libId);
    } catch (e) {
      box = await Hive.openBox(libId);
    }
    final songs = box.values.toList().map((e) {
      final song = MediaItemBuilder.fromJson(e);
      return MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        artUri: song.artUri,
        extras: {"libraryId": libId},
        playable: true,
      );
    }).toList();

    if (!libId.contains("SongDownloads")) {
      await box.close();
    }

    if (libId == "LIBRP") {
      return songs.reversed.toList();
    }

    return songs;
  }
}
