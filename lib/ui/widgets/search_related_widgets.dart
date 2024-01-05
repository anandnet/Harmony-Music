import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/Search/search_result_screen_controller.dart';
import '/models/album.dart';
import '/models/artist.dart';
import '/models/playlist.dart';
import '/ui/widgets/content_list_widget.dart';
import 'separate_tab_item_widget.dart';

class ResultWidget extends StatelessWidget {
  const ResultWidget({super.key, this.isv2Used = false});
  final bool isv2Used;

  @override
  Widget build(BuildContext context) {
    final SearchResultScreenController searchResScrController =
        Get.find<SearchResultScreenController>();
    return Obx(
      () => Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 200, top: isv2Used ? 0 : 70),
            child: searchResScrController.isResultContentFetced.value
                ? Column(children: [
                    if (!isv2Used)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "searchRes".tr,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    if (!isv2Used)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${"for1".tr} \"${searchResScrController.queryString.value}\"",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    ...generateWidgetList(searchResScrController),
                  ])
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  List<Widget> generateWidgetList(
      SearchResultScreenController searchResScrController) {
    List<Widget> list = [];
    for (dynamic item in searchResScrController.resultContent.entries) {
      if (item.key == "Songs" || item.key == "Videos") {
        list.add(SeparateTabItemWidget(
          items: List<MediaItem>.from(item.value),
          title: item.key,
          isCompleteList: false,
        ));
      } else if (item.key == "Albums") {
        list.add(ContentListWidget(
          content: AlbumContent(
              title: item.key, albumList: List<Album>.from(item.value)),
          isHomeContent: false,
        ));
      } else if (item.key.contains("playlist")) {
        list.add(ContentListWidget(
          content: PlaylistContent(
            title: item.key,
            playlistList: List<Playlist>.from(item.value),
          ),
          isHomeContent: false,
        ));
      } else if (item.key.contains("Artist")) {
        list.add(SeparateTabItemWidget(
          items: List<Artist>.from(item.value),
          title: item.key,
          isCompleteList: false,
        ));
      }
    }

    return list;
  }
}
