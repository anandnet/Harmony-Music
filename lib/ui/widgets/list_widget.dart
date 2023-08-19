import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/widgets/marqwee_widget.dart';
import '../../models/playlist.dart';
import '../navigator.dart';
import '../player/player_controller.dart';
import 'image_widget.dart';
import 'songinfo_bottom_sheet.dart';

class ListWidget extends StatelessWidget {
  const ListWidget(this.items, this.title, this.isCompleteList,
      {super.key,
      this.isPlaylist = false,
      this.playlist,
      this.scrollController});
  final List<dynamic> items;
  final String title;
  final bool isCompleteList;
  final ScrollController? scrollController;

  /// Valid for songlist
  final bool isPlaylist;
  final Playlist? playlist;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            "No ${title.toLowerCase()}!",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      );
    } else if (title == "Videos" || title.contains("Songs")) {
      return isCompleteList
          ? Expanded(
              child: listViewSongVid(items,
                  isPlaylist: isPlaylist,
                  playlist: playlist,
                  sc: scrollController))
          : SizedBox(
              height: items.length * 75.0,
              child: listViewSongVid(items),
            );
    } else if (title.contains("playlists")) {
      return listViewPlaylists(items, sc: scrollController);
    } else if (title == "Albums" || title == "Singles") {
      return listViewAlbums(items, sc: scrollController);
    } else if (title.contains('Artists')) {
      return isCompleteList
          ? Expanded(child: listViewArtists(items, sc: scrollController))
          : SizedBox(
              height: items.length * 95.0,
              child: listViewArtists(items),
            );
    }
    return const SizedBox.shrink();
  }

  Widget listViewSongVid(List<dynamic> items,
      {bool isPlaylist = false, Playlist? playlist, ScrollController? sc}) {
    final playerController = Get.find<PlayerController>();
    return Obx(
      () => ListView.builder(
        padding: EdgeInsets.only(
          bottom: Get.find<PlayerController>().isPlayerpanelTopVisible.isTrue
              ? 80
              : 0,
          top: 0,
        ),
        addRepaintBoundaries: false,
        addAutomaticKeepAlives: false,
        controller: sc,
        itemCount: items.length,
        physics: isCompleteList
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            isPlaylist
                ? playerController.playPlayListSong(
                    List<MediaItem>.from(items), index)
                : playerController.pushSongToQueue(items[index] as MediaItem);
          },
          onLongPress: () async {
            showModalBottomSheet(
              isScrollControlled: true,
              context: playerController.homeScaffoldkey.currentState!.context,
              //constraints: BoxConstraints(maxHeight:Get.height),
              barrierColor: Colors.transparent.withAlpha(100),
              builder: (context) => SongInfoBottomSheet(
                items[index] as MediaItem,
                playlist: playlist,
              ),
            ).whenComplete(() => Get.delete<SongInfoController>());
          },
          contentPadding: const EdgeInsets.only(top: 0, left: 5, right: 30),
          leading: ImageWidget(
            size: 55,
            song: items[index],
          ),
          title: MarqueeWidget(
            child: Text(
              items[index].title.length > 50
                  ? items[index].title.substring(0, 50)
                  : items[index].title,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
        ),
      ),
    );
  }

  Widget listViewPlaylists(List<dynamic> playlists, {ScrollController? sc}) {
    return Expanded(
      child: Obx(
        () => ListView.builder(
          padding: EdgeInsets.only(
            bottom: Get.find<PlayerController>().isPlayerpanelTopVisible.isTrue
                ? 80
                : 0,
            top: 0,
          ),
          controller: sc,
          itemCount: playlists.length,
          itemExtent: 100,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => ListTile(
            visualDensity: const VisualDensity(vertical: 4.0),
            isThreeLine: true,
            onTap: () {
              Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
                  id: ScreenNavigationSetup.id,
                  arguments: [false, playlists[index], false]);
            },
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10),
            leading: ImageWidget(
              size: 100,
              playlist: playlists[index],
            ),
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
          ),
        ),
      ),
    );
  }

  Widget listViewAlbums(List<dynamic> albums, {ScrollController? sc}) {
    return Expanded(
      child: Obx(
        () => ListView.builder(
          padding: EdgeInsets.only(
            bottom: Get.find<PlayerController>().isPlayerpanelTopVisible.isTrue
                ? 80
                : 0,
            top: 0,
          ),
          controller: sc,
          itemCount: albums.length,
          itemExtent: 100,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            String artistName = "";
            for (dynamic items in (albums[index].artists).sublist(1)) {
              artistName = "${artistName + items['name']},";
            }
            artistName = artistName.length > 16
                ? artistName.substring(0, 16)
                : artistName;
            return ListTile(
              visualDensity: const VisualDensity(vertical: 4.0),
              isThreeLine: true,
              onTap: () {
                Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
                    id: ScreenNavigationSetup.id,
                    arguments: [true, albums[index], false]);
              },
              contentPadding:
                  const EdgeInsets.only(top: 0, bottom: 0, left: 10),
              leading: ImageWidget(
                size: 100,
                album: albums[index],
              ),
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
      ),
    );
  }

  Widget listViewArtists(List<dynamic> artists, {ScrollController? sc}) {
    return Obx(
      () => ListView.builder(
        padding: EdgeInsets.only(
          bottom: Get.find<PlayerController>().isPlayerpanelTopVisible.isTrue
              ? 80
              : 0,
          top: 5,
        ),
        controller: sc,
        itemCount: artists.length,
        itemExtent: 90,
        physics: isCompleteList
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => ListTile(
          visualDensity: const VisualDensity(horizontal: -2, vertical: 2),
          onTap: () {
            Get.toNamed(ScreenNavigationSetup.artistScreen,
                id: ScreenNavigationSetup.id,
                arguments: [false, artists[index]]);
          },
          contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 5),
          leading: ImageWidget(
            size: 90,
            artist: artists[index],
          ),
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
        ),
      ),
    );
  }
}
