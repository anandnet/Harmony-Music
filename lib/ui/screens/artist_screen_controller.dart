import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../utils/helper.dart';
import '../../models/artist.dart';
import '../utils/home_library_controller.dart';
import '/services/music_service.dart';

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
  Map<String, List> tempListContainer = {};

  @override
  void onReady() {
    final args = Get.arguments;
    _init(args[0], args[1]);
    super.onReady();
  }

  _init(bool isIdOnly, dynamic artist) {
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

    //skip for about page
    if (val == 0 || sepataredContent.containsKey(tabName)) return;
    if (artistData[tabName] == null) {
      isSeparatedArtistContentFetced.value = true;
      return;
    }
    isSeparatedArtistContentFetced.value = false;

    //check if params available for continuation
    //tab browse endpoint & top result stored in [artistData], tabContent & addtionalParams for continuation stored in Separated Content
    if ((artistData[tabName]).containsKey("params")) {
      sepataredContent[tabName] = await musicServices.getArtistRealtedContent(
          artistData[tabName], tabName);
    } else {
      sepataredContent[tabName] = {"results": artistData[tabName]['content']};
      isSeparatedArtistContentFetced.value = true;
      return;
    }

    // observered - continuation available only for song & vid
    if (val == 1 || val == 2) {
      final scrollController =
          val == 1 ? songScrollController : videoScrollController;

      scrollController.addListener(() {
        double maxScroll = scrollController.position.maxScrollExtent;
        double currentScroll = scrollController.position.pixels;
        if (currentScroll >= maxScroll / 2 &&
            sepataredContent[tabName]['additionalParams'] !=
                '&ctoken=null&continuation=null') {
          if (!continuationInProgress) {
            continuationInProgress = true;
            getContinuationContents(artistData[tabName], tabName);
          }
        }
      });
    }
    isSeparatedArtistContentFetced.value = true;
  }

  Future<void> getContinuationContents(browseEndpoint, tabName) async {
    final x = await musicServices.getArtistRealtedContent(
        browseEndpoint, tabName,
        additionalParams: sepataredContent[tabName]['additionalParams']);
    (sepataredContent[tabName]['results']).addAll(x['results']);
    sepataredContent[tabName]['additionalParams'] = x['additionalParams'];
    sepataredContent.refresh();

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

  void onSearchStart(String? tag) {
    final title = tag?.split("_")[0];
    tempListContainer[title!] = sepataredContent[title]['results'].toList();
  }

  void onSearch(String value, String? tag) {
    final title = tag?.split("_")[0];
    final list = tempListContainer[title]!
        .where((element) =>
            element.title.toLowerCase().contains(value.toLowerCase()))
        .toList();
    sepataredContent[title]['results'] = list;
    sepataredContent.refresh();
  }

  void onSearchClose(String? tag) {
    final title = tag?.split("_")[0];
    sepataredContent[title]['results'] = (tempListContainer[title]!).toList();
    sepataredContent.refresh();
    (tempListContainer[title]!).clear();
  }

  @override
  void onClose() {
    tempListContainer.clear();
    songScrollController.dispose();
    videoScrollController.dispose();
    super.onClose();
  }
}
