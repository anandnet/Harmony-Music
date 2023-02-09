import 'package:harmonymusic/models/music_model.dart';
import 'package:just_audio/just_audio.dart';

abstract class CustAudioSource extends UriAudioSource{
  CustAudioSource(this.uri,this.song,):super(uri);
  @override
  Uri uri;
  Song song;
}
