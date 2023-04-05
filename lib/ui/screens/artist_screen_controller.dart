import 'dart:developer';

import 'package:get/get.dart';
import 'package:harmonymusic/services/music_service.dart';

import '../../models/artist.dart';

class ArtistScreenController extends GetxController {
  final isResultContentFetced = false.obs;
  final navigationRailCurrentIndex = 0.obs;
  final musicServices =  Get.find<MusicServices>();
  final railItems = <String>[].obs;
  final artistData = <String,dynamic>{}.obs;
  ArtistScreenController(Artist artist) {
    _fetchArtistContent(artist.browseId);
  }

  Future<void> _fetchArtistContent(String id) async {
     artistData.value = await musicServices.getArtist(id);
    inspect(artistData.value);
  }


  void onDestinationSelected(int val) {
    navigationRailCurrentIndex.value=val;
  }
}
