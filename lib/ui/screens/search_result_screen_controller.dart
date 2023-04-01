import 'package:get/get.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/services/music_service.dart';

class SearchResultScreenController extends GetxController {
  final navigationRailCurrentIndex = 0.obs;
  final isResultContentFetced = false.obs;
  final isSeparatedResultContentFetced = false.obs;
  final resultContent = <String, dynamic>{}.obs;
  final separatedResultContent = <String, dynamic>{}.obs;
  final musicServices = Get.find<MusicServices>();
  final queryString = ''.obs;
  final railItems = <String>[].obs;

  @override
  void onInit() {
    _getInitSearchResult();
    super.onInit();
  }

  Future<void> onDestinationSelected(int value) async {
    isSeparatedResultContentFetced.value = false;
    navigationRailCurrentIndex.value = value;
    if (value != 0 &&
        !separatedResultContent.containsKey(railItems[value - 1])) {
      final tabName = railItems[value - 1];
      final itemCount = (tabName == 'Songs' || tabName == 'Videos') ? 25 : 10;
      separatedResultContent.addAll(await musicServices.search(
          queryString.value,
          filter: tabName.replaceAll(" ", "_").toLowerCase(),
          limit: itemCount));
      isSeparatedResultContentFetced.value = true;
      printINFO(separatedResultContent.keys.first);
    }
    isSeparatedResultContentFetced.value = true;
  }

  void viewAllCallback(String text) {
    onDestinationSelected(railItems.indexOf(text) + 1);
  }

  Future<void> _getInitSearchResult() async {
    queryString.value = Get.arguments;
    resultContent.value = await musicServices.search(queryString.value);
    final allKeys = resultContent.keys.where((element) => ([
          "Songs",
          "Videos",
          "Albums",
          "Featured playlists",
          "Community playlists",
          "Artists"
        ]).contains(element));
    railItems.value = List<String>.from(allKeys);
    isResultContentFetced.value = true;
  }
}
