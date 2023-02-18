import 'song.dart';

class HomeContent{
  HomeContent(this.homePlaylist, {required this.quickPicksSongList});
  final List<Song> quickPicksSongList;
  final List<Song> homePlaylist;
}