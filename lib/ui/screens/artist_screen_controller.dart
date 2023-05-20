import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:hive/hive.dart';

import '../../models/artist.dart';
import '../utils/home_library_controller.dart';

class ArtistScreenController extends GetxController {
  final isArtistContentFetced = false.obs;
  final navigationRailCurrentIndex = 0.obs;
  final musicServices = Get.find<MusicServices>();
  final railItems = <String>[].obs;
  final artistData = <String, dynamic>{}.obs;
  final isAddedToLibrary = false.obs;
  late Artist artist_;
  ArtistScreenController(bool isIdOnly, dynamic artist) {
    if (!isIdOnly) artist_ = artist as Artist;
    _checkIfAddedToLibrary(isIdOnly ? artist as String : artist.browseId);
    _fetchArtistContent(isIdOnly ? artist as String : artist.browseId);
  }

  Future<void> _checkIfAddedToLibrary(String id) async {
    final box = await Hive.openBox("LibraryArtists");
    isAddedToLibrary.value = box.containsKey(id);
    await box.close();
  }

  Future<void> _fetchArtistContent(String id) async {
    artistData.value = await musicServices.getArtist(id);
    isArtistContentFetced.value = true;
    //inspect(artistData.value);
    final data = artistData;
    artist_ = Artist(
        browseId: id,
        name: data['name'],
        thumbnailUrl: data['thumbnails'][0]['url'],
        subscribers: "${data['subscribers']} subscribers",
        radioId: data["radioId"]);
  }

  Future<void> addNremoveFromLibrary({bool add = true}) async {
    try {
      final box = await Hive.openBox("LibraryArtists");
      add
          ? box.put(artist_.browseId, artist_.toJson())
          : box.delete(artist_.browseId);
      isAddedToLibrary.value = add;
      //Update frontend
      Get.find<LibraryArtistsController>().refreshLib();

      Get.snackbar(
          "Info", add ? "Artist Bookmarked" : "Artist Removed from Library",
          duration: const Duration(milliseconds: 1250),
          animationDuration: const Duration(microseconds: 700),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Info", "Operation Failed",
          duration: const Duration(milliseconds: 1250),
          animationDuration: const Duration(seconds: 1));
    }
  }

  void onDestinationSelected(int val) {
    navigationRailCurrentIndex.value = val;
  }
}
