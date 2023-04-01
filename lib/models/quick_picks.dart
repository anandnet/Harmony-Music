import 'package:audio_service/audio_service.dart';
import 'package:harmonymusic/models/media_Item_builder.dart';


class QuickPicks{
  QuickPicks(this.songList);
  List<MediaItem> songList;

  factory QuickPicks.fromJson(Map<dynamic,dynamic> json)=>QuickPicks((json['contents']).map<MediaItem>((item)=>MediaItemBuilder.fromJson(item)).toList());
}