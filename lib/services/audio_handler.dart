import 'dart:io';
import 'dart:isolate';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/background_task.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:rxdart/src/subjects/publish_subject.dart';

import '../models/song.dart';
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
  late final _cacheDir;
  final _player = AudioPlayer();
  var currentIndex;
  String nextSongUrl = '';
  final _songsUrlCacheBox = Hive.box("SongsUrlCache");
  final _songsCacheBox = Hive.box("SongsCache");
  final _musicServices = Get.find<MusicServices>();
  final _playList = ConcatenatingAudioSource(
    children: [],
  );
  late final _appdocdir;

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
    _appdocdir = (await getApplicationDocumentsDirectory()).path;
    if (!Directory("$_cacheDir/cachedSongs/").existsSync()) {
      Directory("$_cacheDir/cachedSongs/").createSync(recursive: true);
    }
  }

  void _addEmptyList() {
    try {
      _player.setAudioSource(_playList);
    } catch (r) {
      print(r);
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
        print('Error code: ${e.code}');
        print('Error message: ${e.message}');
      } else {
        print('An error occurred: $e');
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
    List<String> qidList =
        mediaItems.map((item) => item.id).whereType<String>().toList();
    Isolate.spawn(cacheQueueitemsUrl,[_appdocdir,mediaItems]);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // notify system
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    final newQueue = this.queue.value
      ..replaceRange(0, this.queue.value.length, queue);
    this.queue.add(newQueue);
    //maybe we can use isolate for this in future
    //cache queue item url for better song skiping
    List<String> qidList =
        queue.map((item) => item.id).whereType<String>().toList();
    await Isolate.spawn(cacheQueueitemsUrl,[_appdocdir, queue]);
  }

 

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) {
    // TODO: implement insertQueueItem
    return super.insertQueueItem(index, mediaItem);
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
    } else if (name == 'setSourceNPlay') {
      await _playList.clear();
      await _playList.add(_createAudioSource(
          Song.fromJson(extras!['song'], url: extras['url']).toMediaItem()));
      await _player.play();
    } else if (name == 'playByIndex') {
      currentIndex = extras!['index'];
      final currentSong = queue.value[currentIndex];
      mediaItem.add(currentSong);
      currentSong.extras!['url'] = await checkNGetUrl(currentSong.id);
      playbackState.add(playbackState.value.copyWith(queueIndex: currentIndex));
      await _playList.clear();
      await _playList.add(_createAudioSource(currentSong));

      await _player.play();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  Future<String?> checkNGetUrl(String songId) async {
    if (_songsCacheBox.containsKey(songId)) {
      return (_songsCacheBox.get(songId) as Song).url;
    } else {
      //check if song stream url is cached and allocate url accordingly
      String url = "";
      if (_songsUrlCacheBox.containsKey(songId)) {
        if (_isUrlExpired(_songsUrlCacheBox.get(songId))) {
          url = (await _musicServices.getSongUri(songId)).toString();
          _songsUrlCacheBox.put(songId, url);
        } else {
          url = _songsUrlCacheBox.get(songId);
        }
      } else {
        url = (await _musicServices.getSongUri(songId)).toString();
        _songsUrlCacheBox.put(songId, url);
      }
      return url;
    }
  }

  ///Check if Steam Url is expired
  bool _isUrlExpired(String url) {
    RegExpMatch? match = RegExp(".expire=([0-9]+)?&").firstMatch(url);
    if (match != null) {
      if (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1800 <
          int.parse(match[1]!)) {
        print("Not Expired");
        return false;
      }
    }
    print("Expired");
    return true;
  }
}
