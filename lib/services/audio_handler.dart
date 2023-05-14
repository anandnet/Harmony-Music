import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/models/media_Item_builder.dart';
import 'package:harmonymusic/services/utils.dart';
import 'package:harmonymusic/ui/screens/settings_screen_controller.dart';
import 'package:hive/hive.dart';

import 'package:just_audio/just_audio.dart';

import 'package:path_provider/path_provider.dart';

import '../ui/utils/home_library_controller.dart';
import 'music_service.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
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
  late String currentSongUrl;
  bool isPlayingUsingLockCachingSource = false;
  bool loopModeEnabled = false;

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
        await _player.stop();
        await customAction("setSourceNPlay",
            {'mediaItem': queue.value[currentIndex], 'retry': true});
        // Duration curPos = _player.position;
        // await _player.stop();
        // await _player.seek(curPos,index:0);
        // await _player.play();
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
    printINFO(loopModeEnabled);
    if (loopModeEnabled) {
      printINFO("here");
      _player.seek(Duration.zero);
      _player.play();
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
    printINFO(url);
    if (url.contains('file') ||
        Get.find<SettingsScreenController>().cacheSongs.isTrue) {
      printINFO("Play Using LockCaching");
      isPlayingUsingLockCachingSource = true;
      return LockCachingAudioSource(
        Uri.parse(url),
        cacheFile: File("$_cacheDir/cachedSongs/${mediaItem.id}.mp3"),
        tag: mediaItem,
      );
    }

    printINFO("Play Using AudioSource.uri");
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
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }
    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() async {
    _player.seek(Duration.zero);
    if (queue.value.length > currentIndex + 1) {
      await customAction("playByIndex", {'index': currentIndex + 1});
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
      loopModeEnabled= false;
    } else {
      loopModeEnabled= true;
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    } else if (name == 'playByIndex') {
      await _playList.clear();
      currentIndex = extras!['index'];
      final currentSong = queue.value[currentIndex];
      mediaItem.add(currentSong);
      currentSong.extras!['url'] = await checkNGetUrl(currentSong.id);
      currentSongUrl = currentSong.extras!['url'];
      playbackState.add(playbackState.value.copyWith(queueIndex: currentIndex));

      await _playList.add(_createAudioSource(currentSong));

      await _player.play();
    } else if (name == "checkWithCacheDb" && isPlayingUsingLockCachingSource) {
      final song = extras!['mediaItem'] as MediaItem;
      final songsCacheBox = Hive.box("SongsCache");
      if (!songsCacheBox.containsKey(song.id)) {
        song.extras!['url'] = currentSongUrl;
        songsCacheBox.put(song.id, MediaItemBuilder.toJson(song));
        if (!librarySongsController.isClosed) {
          librarySongsController.cachedSongsList.value =
              librarySongsController.cachedSongsList.value + [song];
        }
      }
    } else if (name == 'setSourceNPlay') {
      await _playList.clear();
      final currMed = (extras!['mediaItem'] as MediaItem);
      if (!extras['retry']) {
        currentIndex = 0;
        mediaItem.add(currMed);
        queue.add([currMed]);
      }
      currentSongUrl =
          (await checkNGetUrl(currMed.id, generateNewUrl: extras['retry']))!;
      currMed.extras!['url'] = currentSongUrl;
      printINFO("song urk got");
      await _playList.add(_createAudioSource(currMed));
      await _player.play();
    } else if (name == 'toggleSkipSilence') {
      final enable = (extras!['enable'] as bool);
      await _player.setSkipSilenceEnabled(enable);
      printINFO(enable);
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  Future<String?> checkNGetUrl(String songId,
      {bool generateNewUrl = false}) async {
    final songsCacheBox = Hive.box("SongsCache");
    if (songsCacheBox.containsKey(songId) && !generateNewUrl) {
      printINFO("Got Song from cachedbox ($songId)");
      return "file://$_cacheDir/cachedSongs/$songId.mp3";
    } else {
      //check if song stream url is cached and allocate url accordingly
      final songsUrlCacheBox = Hive.box("SongsUrlCache");
      final qualityIndex = Hive.box('AppPrefs').get('streamingQuality');
      final musicServices = Get.find<MusicServices>();
      List<String> url = [];
      if (songsUrlCacheBox.containsKey(songId) && !generateNewUrl) {
        if (isExpired(url: songsUrlCacheBox.get(songId)[qualityIndex])) {
          url = (await musicServices.getSongUri(songId))!;
          songsUrlCacheBox.put(songId, url);
        } else {
          url = songsUrlCacheBox.get(songId);
        }
      } else {
        url = (await musicServices.getSongUri(songId))!;
        songsUrlCacheBox.put(songId, url);
        printINFO("Url cached in Box for songId $songId");
      }
      printINFO("index :${AudioQuality.values} $qualityIndex");
      return url[qualityIndex];
    }
  }
}
