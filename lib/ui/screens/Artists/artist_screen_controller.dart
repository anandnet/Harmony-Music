import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../widgets/add_to_playlist.dart';
import '/ui/widgets/sort_widget.dart';
import '../../../models/artist.dart';
import '../../../utils/helper.dart';
import '../Library/library_controller.dart';
import '/services/music_service.dart';
import '/ui/screens/Home/home_screen_controller.dart';
import '/ui/screens/Settings/settings_screen_controller.dart';

class ArtistScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
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
  SortWidgetController? sortWidgetController;
  final additionalOperationMode = OperationMode.none.obs;
  bool continuationInProgress = false;
  late Artist artist_;
  Map<String, List> tempListContainer = {};
  TabController? tabController;
  bool isTabTransitionReversed = false;

  @override
  void onInit() {
    final args = Get.arguments;
    _init(args[0], args[1]);
    if (GetPlatform.isDesktop ||
        Get.find<SettingsScreenController>().isBottomNavBarEnabled.isTrue) {
      tabController = TabController(vsync: this, length: 5);
      tabController?.animation?.addListener(() {
        int indexChange = tabController!.offset.round();
        int index = tabController!.index + indexChange;

        if (index != navigationRailCurrentIndex.value) {
          onDestinationSelected(index);
          navigationRailCurrentIndex.value = index;
        }
      });
    }
    super.onInit();
  }

  @override
  void onReady() {
    Get.find<HomeScreenController>().whenHomeScreenOnTop();
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
    isTabTransitionReversed = val > navigationRailCurrentIndex.value;
    navigationRailCurrentIndex.value = val;
    final tabName = ["About", "Songs", "Videos", "Albums", "Singles"][val];

    //cancel additional operations in case of tab change
    if (sortWidgetController != null) {
      sortWidgetController?.setActiveMode(OperationMode.none);
      cancelAdditionalOperation();
    }

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

  void onSort(SortType sortType, bool isAscending, String title) {
    if (sepataredContent[title] == null) {
      return;
    }
    if (title == "Songs" || title == "Videos") {
      final songlist = sepataredContent[title]['results'].toList();
      sortSongsNVideos(songlist, sortType, isAscending);
      sepataredContent[title]['results'] = songlist;
    } else if (title == "Albums" || title == "Singles") {
      final albumList = sepataredContent[title]['results'].toList();
      sortAlbumNSingles(albumList, sortType, isAscending);
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

  //Additional operations
  final additionalOperationTempList = <MediaItem>[].obs;
  final additionalOperationTempMap = <int, bool>{}.obs;

  void startAdditionalOperation(
      SortWidgetController sortWidgetController_, OperationMode mode) {
    sortWidgetController = sortWidgetController_;
    final tabName = [
      "About",
      "Songs",
      "Videos",
      "Albums",
      "Singles"
    ][navigationRailCurrentIndex.value];
    additionalOperationTempList.value =
        sepataredContent[tabName]['results'].toList();
    if (mode == OperationMode.addToPlaylist || mode == OperationMode.delete) {
      for (int i = 0; i < additionalOperationTempList.length; i++) {
        additionalOperationTempMap[i] = false;
      }
    }
    additionalOperationMode.value = mode;
  }

  void checkIfAllSelected() {
    sortWidgetController!.isAllSelected.value =
        !additionalOperationTempMap.containsValue(false);
  }

  void selectAll(bool selected) {
    for (int i = 0; i < additionalOperationTempList.length; i++) {
      additionalOperationTempMap[i] = selected;
    }
  }

  void performAdditionalOperation() {
    final currMode = additionalOperationMode.value;
    if (currMode == OperationMode.addToPlaylist) {
      showDialog(
        context: Get.context!,
        builder: (context) => AddToPlaylist(selectedSongs()),
      ).whenComplete(() {
        Get.delete<AddToPlaylistController>();
        sortWidgetController?.setActiveMode(OperationMode.none);
        cancelAdditionalOperation();
      });
    }
  }

  List<MediaItem> selectedSongs() {
    return additionalOperationTempMap.entries
        .map((item) {
          if (item.value) {
            return additionalOperationTempList[item.key];
          }
        })
        .whereType<MediaItem>()
        .toList();
  }

  void cancelAdditionalOperation() {
    sortWidgetController!.isAllSelected.value = false;
    sortWidgetController = null;
    additionalOperationMode.value = OperationMode.none;
    additionalOperationTempList.clear();
    additionalOperationTempMap.clear();
  }

  @override
  void onClose() {
    tempListContainer.clear();
    songScrollController.dispose();
    videoScrollController.dispose();
    tabController?.dispose();
    Get.find<HomeScreenController>().whenHomeScreenOnTop();
    super.onClose();
  }
}
