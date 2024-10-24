import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/models/artist.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/ui/screens/Search/search_result_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/content_list_widget.dart';
import 'package:harmonymusic/ui/widgets/separate_tab_item_widget.dart';

class ResultWidget extends StatelessWidget {
  const ResultWidget({super.key, this.isv2Used = false});

  final bool isv2Used;

  @override
  Widget build(BuildContext context) {
    final searchResScrController = Get.find<SearchResultScreenController>();
    final topPadding = context.isLandscape ? 50.0 : 80.0;
    return Obx(
      () => Center(
        child: Padding(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 200, top: isv2Used ? 0 : topPadding),
            child: searchResScrController.isResultContentFetced.value
                ? column.children([
                    if (!isv2Used)
                      column.children([
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'searchRes'.tr,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${"for1".tr} "${searchResScrController.queryString.value}"',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ]),
                    const SizedBox(height: 10),
                    ...generateWidgetList(searchResScrController),
                  ])
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  List<Widget> generateWidgetList(SearchResultScreenController searchResScrController) {
    var list = <Widget>[];
    for (dynamic item in searchResScrController.resultContent.entries) {
      if (item.key == 'Songs' || item.key == 'Videos') {
        list.add(SeparateTabItemWidget(
          items: List<MediaItem>.from(item.value),
          title: item.key,
          isCompleteList: false,
        ));
      } else if (item.key == 'Albums') {
        list.add(ContentListWidget(
          content: AlbumContent(title: item.key, albumList: List<Album>.from(item.value)),
          isHomeContent: false,
        ));
      } else if (item.key.contains('playlist')) {
        list.add(ContentListWidget(
          content: PlaylistContent(
            title: item.key,
            playlistList: List<Playlist>.from(item.value),
          ),
          isHomeContent: false,
        ));
      } else if (item.key.contains('Artist')) {
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
