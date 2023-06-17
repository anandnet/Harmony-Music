import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:hive/hive.dart';

import '../../helper.dart';
import '../../models/artist.dart';
import '../utils/home_library_controller.dart';

class ArtistScreenController extends GetxController {
  final isArtistContentFetced = false.obs;
  final navigationRailCurrentIndex = 0.obs;
  final musicServices = Get.find<MusicServices>();
  final railItems = <String>[].obs;
  final artistData = <String, dynamic>{}.obs;
  final sepataredContent = <String, dynamic>{}.obs;
  final isSeparatedArtistContentFetced = false.obs;
  final isAddedToLibrary = false.obs;
  final songScrollController = ScrollController();
  final videoScrollController = ScrollController();
  bool continuationInProgress = false;
  late Artist artist_;
  ArtistScreenController(bool isIdOnly, dynamic artist) {
    if (!isIdOnly) artist_ = artist as Artist;
    _fetchArtistContent(isIdOnly ? artist as String : artist.browseId);
    _checkIfAddedToLibrary(isIdOnly ? artist as String : artist.browseId);
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
        thumbnailUrl:
            data['thumbnails'] != null ? data['thumbnails'][0]['url'] : "",
        subscribers: "${data['subscribers']} subscribers",
        radioId: data["radioId"]);
  }

  Future<bool> addNremoveFromLibrary({bool add = true}) async {
    try {
      final box = await Hive.openBox("LibraryArtists");
      add
          ? box.put(artist_.browseId, artist_.toJson())
          : box.delete(artist_.browseId);
      isAddedToLibrary.value = add;
      //Update frontend
      Get.find<LibraryArtistsController>().refreshLib();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> onDestinationSelected(int val) async {
    navigationRailCurrentIndex.value = val;
    final tabName = ["About", "Songs", "Videos", "Albums", "Singles"][val];

    if (val == 0 || sepataredContent.containsKey(tabName)) return;
    if (artistData[tabName] == null) {
      isSeparatedArtistContentFetced.value = true;
      return;
    }
    isSeparatedArtistContentFetced.value = false;
    sepataredContent[tabName] = await musicServices.getArtistRealtedContent(
        artistData[tabName], tabName);
    if (val == 1 || val == 2) {
      final scrollController =
          val == 1 ? songScrollController : videoScrollController;

      scrollController.addListener(() {
        double maxScroll = scrollController.position.maxScrollExtent;
        double currentScroll = scrollController.position.pixels;
        double delta = 300.0;
        if (maxScroll - currentScroll <= delta) {
          if (!continuationInProgress) {
            printINFO("InProgrss");
            continuationInProgress = true;
            getContinuationContents(artistData[tabName], tabName);
          }
        }
      });
    }
    isSeparatedArtistContentFetced.value = true;
  }

  Future<void> getContinuationContents(browseEndpoint, tabName) async {
    if (sepataredContent[tabName]['additionalParams'] !=
        '&ctoken=null&continuation=null') {
      final x = await musicServices.getArtistRealtedContent(
          browseEndpoint, tabName,
          additionalParams: sepataredContent[tabName]['additionalParams']);
      (sepataredContent[tabName]['results']).addAll(x['results']);
      sepataredContent[tabName]['additionalParams'] = x['additionalParams'];
      sepataredContent.refresh();
    }

    continuationInProgress = false;
  }

  void onSort(bool sortByName, bool sortByDate, bool sortByDuration,
      bool isAscending, String title) {
    if (sepataredContent[title] == null) {
      return;
    }
    if (title == "Songs" || title == "Videos") {
      final songlist = sepataredContent[title]['results'].toList();
      sortSongsNVideos(
          songlist, sortByName, sortByDate, sortByDuration, isAscending);
      sepataredContent[title]['results'] = songlist;
    } else if (title == "Albums" || title == "Singles") {
      final albumList = sepataredContent[title]['results'].toList();
      sortAlbumNSingles(albumList, sortByName, sortByDate, isAscending);
      sepataredContent[title]['results'] = albumList;
    }
    sepataredContent.refresh();
  }

  @override
  void onClose() {
    songScrollController.dispose();
    videoScrollController.dispose();
    super.onClose();
  }
}
