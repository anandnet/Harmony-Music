import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/search_result_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/content_list_widget.dart';

import '../navigator.dart';
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
                    const SizedBox(
                      height: 10,
                    ),
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
      this.topPadding = 0});
  final List<dynamic> items;
  final String title;
  final bool isCompleteList;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final scresController = Get.find<SearchResultScreenController>();
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
                          scresController.viewAllCallback(title);
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
          getListView(items, title, isCompleteList),
        ],
      ),
    );
  }

  Widget getListView(items, String title, bool isCompleteList) {
    if (title == "Videos" || title == "Songs") {
      return isCompleteList
          ? Expanded(child: listViewSongVid(items, isCompleteList))
          : SizedBox(
              height: items.length * 75.0,
              child: listViewSongVid(items, isCompleteList),
            );
    } else if (title.contains("playlists")) {
      return listViewPlaylists(items);
    } else if (title == "Albums" || title == "Singles" ) {
      return listViewAlbums(items);
    } else if (title == 'Artists') {
      return listViewArtists(items);
    }
    return const SizedBox.shrink();
  }

  Widget listViewSongVid(List<dynamic> items, bool isCompleteList) {
    final playerController = Get.find<PlayerController>();
    return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        physics: isCompleteList
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => ListTile(
              onTap: () {
                playerController.pushSongToQueue(items[index] as MediaItem);
              },
              contentPadding: const EdgeInsets.only(top: 0, left: 5, right: 30),
              leading: SizedBox.square(
                  dimension: 50,
                  child: ImageWidget(
                    song: items[index],
                  )),
              title: Text(
                items[index].title,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                "${items[index].artist}",
                maxLines: 1,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              trailing: Text(
                items[index].extras!['length'] ?? "",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ));
  }

  Widget listViewPlaylists(List<dynamic> playlists) {
    return Expanded(
      child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: playlists.length,
          itemExtent: 100,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => ListTile(
                visualDensity: const VisualDensity(vertical: 4.0),
                isThreeLine: true,
                onTap: () {
                  Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
                      id: ScreenNavigationSetup.id,
                      arguments: [false, playlists[index]]);
                },
                contentPadding:
                    const EdgeInsets.only(top: 0, bottom: 0, left: 10),
                leading: SizedBox.square(
                    dimension: 100,
                    child: ImageWidget(
                      playlist: playlists[index],
                      isMediumImage: true,
                    )),
                title: Text(
                  playlists[index].title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  playlists[index].description,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              )),
    );
  }

  Widget listViewAlbums(List<dynamic> albums) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: albums.length,
        itemExtent: 100,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          String artistName = "";
          for (dynamic items in (albums[index].artists).sublist(1)) {
            artistName = "${artistName + items['name']},";
          }
          artistName =
              artistName.length > 16 ? artistName.substring(0, 16) : artistName;
          return ListTile(
            visualDensity: const VisualDensity(vertical: 4.0),
            isThreeLine: true,
            onTap: () {
              Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
                  id: ScreenNavigationSetup.id,
                  arguments: [true, albums[index]]);
            },
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10),
            leading: SizedBox.square(
                dimension: 100,
                child: ImageWidget(
                  album: albums[index],
                  isMediumImage: true,
                )),
            title: Text(
              albums[index].title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              "$artistName\n${(albums[index].artists[0]['name'])} • ${albums[index].year}",
              maxLines: 2,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          );
        },
      ),
    );
  }

  Widget listViewArtists(List<dynamic> artists) {
    return Expanded(
      child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: artists.length,
          itemExtent: 90,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => ListTile(
                visualDensity: const VisualDensity(horizontal: -2, vertical: 2),
                onTap: () {
                  Get.toNamed(ScreenNavigationSetup.artistScreen,
                      id: ScreenNavigationSetup.id, arguments: artists[index]);
                },
                contentPadding:
                    const EdgeInsets.only(top: 0, bottom: 0, left: 5),
                leading: Container(
                    height: 90,
                    width: 90,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ImageWidget(
                      artist: artists[index],
                      isMediumImage: true,
                    )),
                title: Text(
                  artists[index].name,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  artists[index].subscribers,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              )),
    );
  }
}
