import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/models/album.dart';
import '/models/artist.dart';
import '/models/playlist.dart';
import '/ui/screens/artist_screen_controller.dart';
import '/ui/screens/search_result_screen_controller.dart';
import '/ui/widgets/content_list_widget.dart';
import '/ui/widgets/sort_widget.dart';
import 'list_widget.dart';
import 'loader.dart';

class ResultWidget extends StatelessWidget {
  const ResultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchResultScreenController searchResScrController =
        Get.find<SearchResultScreenController>();
    return Obx(
      () => Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 84, top: 70),
            child: searchResScrController.isResultContentFetced.value
                ? Column(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Search Results",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "for \"${searchResScrController.queryString.value}\"",
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
        list.add(SeparateSearchItemWidget(
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
        list.add(SeparateSearchItemWidget(
          items: List<Artist>.from(item.value),
          title: item.key,
          isCompleteList: false,
        ));
      }
    }

    return list;
  }
}

class SeparateSearchItemWidget extends StatelessWidget {
  const SeparateSearchItemWidget(
      {super.key,
      required this.items,
      required this.title,
      this.isCompleteList = true,
      this.isResultWidget = true,
      this.topPadding = 0,
      this.scrollController,this.artistControllerTag});
  /// tag for accessing Artist controller inst, [artistControllerTag] only valid for Artist screen
  final String? artistControllerTag; 
  final List<dynamic> items;
  final String title;
  final bool isCompleteList;
  final double topPadding;
  final bool isResultWidget;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final artistController = Get.isRegistered<ArtistScreenController>(tag: artistControllerTag)
        ? Get.find<ArtistScreenController>(tag: artistControllerTag)
        : null;
    final searchResController = Get.isRegistered<SearchResultScreenController>()
        ? Get.find<SearchResultScreenController>()
        : null;
    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 5),
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                isCompleteList
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: () {
                          searchResController!.viewAllCallback(title);
                        },
                        child: Text("View all",
                            style: Theme.of(Get.context!).textTheme.titleSmall))
              ],
            ),
          ),
          isCompleteList
              ? Obx(() => SortWidget(
                tag: "${title}_$artistControllerTag",
                isSearchFeatureRequired: artistController!=null,
                  titleLeftPadding: 9,
                  itemCountTitle:
                      "${isResultWidget ? (searchResController?.separatedResultContent[title] ?? []).length : (artistController?.sepataredContent[title] != null ? artistController?.sepataredContent[title]['results'] : []).length} items",
                  isDurationOptionRequired:
                      title == "Songs" || title == "Videos",
                  isDateOptionRequired: title == 'Albums' || title == "Singles",
                  onSort: (a, b, c, d) {
                    isResultWidget
                        ? searchResController!.onSort(a, b, c, d, title)
                        : artistController?.onSort(a, b, c, d, title);
                  },
                  onSearch: artistController?.onSearch,
                    onSearchClose: artistController?.onSearchClose,
                    onSearchStart: artistController?.onSearchStart,
                  ))
              : const SizedBox.shrink(),
          isCompleteList
              ? isResultWidget
                  ? GetX<SearchResultScreenController>(builder: (controller) {
                      if (controller.isSeparatedResultContentFetced.isTrue) {
                        return ListWidget(
                          controller.separatedResultContent[title],
                          title,
                          isCompleteList,
                          scrollController: scrollController,
                        );
                      } else {
                        return const Expanded(
                            child: Center(child: LoadingIndicator()));
                      }
                    })
                  : (artistController!.isArtistContentFetced.isTrue
                      ? ListWidget(
                          items,
                          title,
                          isCompleteList,
                          scrollController: scrollController,
                        )
                      : const Expanded(
                          child: Center(child: LoadingIndicator())))
              : ListWidget(
                  items,
                  title,
                  isCompleteList,
                  scrollController: scrollController,
                ),
        ],
      ),
    );
  }
}
