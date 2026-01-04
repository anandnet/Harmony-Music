// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

class PlayingFrom {
  PlayingFromType type;
  String name;

  PlayingFrom({required this.type, this.name = ""});

  get typeString {
    switch (type) {
      case PlayingFromType.ALBUM:
        return "playingfromAlbum".tr;
      case PlayingFromType.PLAYLIST:
        return "playingfromPlaylist".tr;
      case PlayingFromType.SELECTION:
        return "playingfromSelection".tr;
      case PlayingFromType.ARTIST:
        return "playingfromArtist".tr;
    }
  }

  get nameString {
    if (type == PlayingFromType.SELECTION) return "randomSelection".tr;
    return name;
  }
}

enum PlayingFromType { ALBUM, PLAYLIST, SELECTION, ARTIST }
