import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/ui/screens/search_result_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/content_list_widget.dart';

import 'image_widget.dart';

class ResultWidget extends StatelessWidget {
  const ResultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchResultScreenController searchResScrController =
        Get.find<SearchResultScreenController>();
    return Obx(
      () => Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90, top: 70),
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
                    const SizedBox(height: 10,),
                    ...generateWidgetList(searchResScrController)
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
        list.add(SongVideoWidget(
            mediaItems: List<MediaItem>.from(item.value), title: item.key));
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
      }
    }

    return list;
  }
}

class SongVideoWidget extends StatelessWidget {
  const SongVideoWidget(
      {super.key, required this.mediaItems, required this.title});
  final List<dynamic> mediaItems;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              TextButton(onPressed: () {}, child: const Text("View all"))
            ],
          ),
        ),
        SizedBox(
          height: mediaItems.length * 75,
          child: ListView(
            padding: EdgeInsets.zero,
            children: mediaItems
                .map((item) => ListTile(
                      onTap: () {},
                      contentPadding:
                          const EdgeInsets.only(top: 0, left: 0, right: 30),
                      leading: SizedBox.square(
                          dimension: 50,
                          child: ImageWidget(
                            song: item,
                          )),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        "${item.artist}",
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      trailing: Text(
                        item.extras!['length'] ?? "",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ))
                .toList(),
          ),
        )
      ],
    );
  }
}
