import 'package:audio_service/audio_service.dart';

class QuickPicks {
  QuickPicks(this.songList, {this.title = "Discover"});
  List<MediaItem> songList;
  final String title;
}
