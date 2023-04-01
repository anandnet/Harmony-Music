import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/models/media_Item_builder.dart';
import 'package:harmonymusic/services/utils.dart';
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

  final _playList = ConcatenatingAudioSource(
    children: [],
  );
  HomeLibrayController homeLibrayController = Get.find<HomeLibrayController>();

  MyAudioHandler() {
    _createCacheDir();
    _addEmptyList();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenToPlaybackForNextSong();
    _listenForSequenceStateChanges();
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
    }, onError: (Object e, StackTrace st) {
      if (e is PlayerException) {
        printERROR('Error code: ${e.code}');
        printERROR('Error message: ${e.message}');
      } else {
        printERROR('An error occurred: $e');
      }
    });
  }

  void _listenToPlaybackForNextSong() {
    _player.positionStream.listen((value) {
      if (_player.duration != null &&
          value.inMilliseconds >= _player.duration!.inMilliseconds) {
        skipToNext();
      }
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
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

  LockCachingAudioSource _createAudioSource(MediaItem mediaItem) {
    return LockCachingAudioSource(
      Uri.parse(mediaItem.extras!['url'] as String),
      cacheFile: File("$_cacheDir/cachedSongs/${mediaItem.id}.mp3"),
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
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    } else if (name == 'setSourceNPlay1') {
      await _playList.clear();
      final currMed = (extras!['mediaItem'] as MediaItem);
      queue.add(queue.value..replaceRange(0, queue.value.length, [currMed]));
      currentIndex = 0;
      mediaItem.add(currMed);
      currentSongUrl = (await checkNGetUrl(currMed.id))!;
      currMed.extras!['url'] = currentSongUrl;
      await _playList.add(_createAudioSource(currMed));
      await _player.play();
      final musicServices = Get.find<MusicServices>();
      final response =
          await musicServices.getWatchPlaylist(videoId: currMed.id);
      List<MediaItem> upNextSongList = (response['tracks'])
          .map<MediaItem>((item) => MediaItemBuilder.fromJson(item))
          .toList();
      await updateQueue(upNextSongList);
     
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
    } else if (name == "checkWithCacheDb") {
      final song = extras!['mediaItem'] as MediaItem;
      final songsCacheBox = Hive.box("SongsCache");
      if (!songsCacheBox.containsKey(song.id)) {
        song.extras!['url'] = currentSongUrl;
        songsCacheBox.put(song.id, MediaItemBuilder.toJson(song));
        if (!homeLibrayController.isClosed) {
          homeLibrayController.cachedSongsList.value =
              homeLibrayController.cachedSongsList + [song];
        }
      }
    } else if (name == 'setSourceNPlay') {
      await _playList.clear();
      final currMed = (extras!['mediaItem'] as MediaItem);
      currentIndex = 0;
      mediaItem.add(currMed);
      queue.add([currMed]);
      currentSongUrl = (await checkNGetUrl(currMed.id))!;
      currMed.extras!['url'] = currentSongUrl;
      await _playList.add(_createAudioSource(currMed));
      await _player.play();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  Future<String?> checkNGetUrl(String songId) async {
    final songsCacheBox = Hive.box("SongsCache");
    if (songsCacheBox.containsKey(songId)) {
      printINFO("Song is cached ($songId)");
      return songsCacheBox.get(songId)['url'];
    } else {
      //check if song stream url is cached and allocate url accordingly
      final songsUrlCacheBox = Hive.box("SongsUrlCache");
      final musicServices = Get.find<MusicServices>();
      String url = "";
      if (songsUrlCacheBox.containsKey(songId)) {
        if (isExpired(url: songsUrlCacheBox.get(songId))) {
          url = (await musicServices.getSongUri(songId)).toString();
          songsUrlCacheBox.put(songId, url);
        } else {
          url = songsUrlCacheBox.get(songId);
        }
      } else {
        url = (await musicServices.getSongUri(songId)).toString();
        songsUrlCacheBox.put(songId, url);
        printINFO("Url is cached in Box for songId $songId");
      }
      return url;
    }
  }
}
