// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

class PlaylingFrom {
  PlaylingFromType type;
  String name;

  PlaylingFrom({required this.type, this.name = ""});

  get typeString {
    switch (type) {
      case PlaylingFromType.ALBUM:
        return "playingfromAlbum".tr;
      case PlaylingFromType.PLAYLIST:
        return "playingfromPlaylist".tr;
      case PlaylingFromType.SELECTION:
        return "playingfromSelection".tr;
      case PlaylingFromType.ARTIST:
        return "playingfromArtist".tr;
    }
  }

  get nameString {
    if (type == PlaylingFromType.SELECTION) return "randomSelection".tr;
    return name;
  }
}

enum PlaylingFromType { ALBUM, PLAYLIST, SELECTION, ARTIST }
