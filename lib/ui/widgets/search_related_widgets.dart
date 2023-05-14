import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/models/artist.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/ui/screens/artist_screen_controller.dart';
import 'package:harmonymusic/ui/screens/search_result_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/content_list_widget.dart';
import 'package:harmonymusic/ui/widgets/shimmer_widgets/song_list_shimmer.dart';

import 'list_widget.dart';

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
      printINFO(item.key);
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
      this.topPadding = 0});
  final List<dynamic> items;
  final String title;
  final bool isCompleteList;
  final double topPadding;
  final bool isResultWidget;

  @override
  Widget build(BuildContext context) {
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
                          Get.find<SearchResultScreenController>()
                              .viewAllCallback(title);
                        },
                        child: Text("View all",
                            style: Theme.of(Get.context!).textTheme.titleSmall))
              ],
            ),
          ),
          isCompleteList
              ? const SizedBox(
                  height: 20,
                )
              : const SizedBox.shrink(),
          isCompleteList
              ? isResultWidget
                  ? GetX<SearchResultScreenController>(builder: (controller) {
                      if (controller.isSeparatedResultContentFetced.isTrue) {
                        return ListWidget(
                            Get.find<SearchResultScreenController>()
                                .separatedResultContent[title],
                            title,
                            isCompleteList);
                      } else {
                        return const Expanded(child: SongListShimmer());
                      }
                    })
                  : (Get.find<ArtistScreenController>()
                          .isArtistContentFetced
                          .isTrue
                      ? ListWidget(items, title, isCompleteList)
                      : const Expanded(child: SongListShimmer()))
              : ListWidget(items, title, isCompleteList),
        ],
      ),
    );
  }
}
