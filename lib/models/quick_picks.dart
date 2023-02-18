import 'song.dart';

class QuickPicks{
  QuickPicks(this.songList);
  List<Song> songList;

  factory QuickPicks.fromJson(Map<dynamic,dynamic> json)=>QuickPicks((json['contents']).map<Song>((item)=>Song.fromJson(item)).toList());
}