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
      this.isArtistSongs = false,
      this.playlist,
      this.scrollController});
  final List<dynamic> items;
  final String title;
  final bool isCompleteList;
  final ScrollController? scrollController;

  /// Valid for songlist
  final bool isArtistSongs;
  final bool isPlaylist;
  final Playlist? playlist;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            "No ${title.toLowerCase().tr}!",
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
                  sc: scrollController,
                  isArtistSongs: isArtistSongs))
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
      {bool isPlaylist = false,
      Playlist? playlist,
      bool isArtistSongs = false,
      ScrollController? sc}) {
    final playerController = Get.find<PlayerController>();
    return ListView.builder(
      padding: const EdgeInsets.only(
        bottom: 200,
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
          (isPlaylist || isArtistSongs)
              ? playerController.playPlayListSong(
                  List<MediaItem>.from(items), index)
              : playerController.pushSongToQueue(items[index] as MediaItem);
        },
        onLongPress: () async {
          showModalBottomSheet(
            constraints: const BoxConstraints(maxWidth: 500),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
            ),
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
        trailing: SizedBox(
          width: Get.size.width > 800 ? 80 : 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isPlaylist)
                    Obx(() => playerController.currentSong.value?.id ==
                            items[index].id
                        ? const Icon(
                            Icons.equalizer_rounded,
                          )
                        : const SizedBox.shrink()),
                  Text(
                    items[index].extras!['length'] ?? "",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              if (GetPlatform.isDesktop)
                IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      showModalBottomSheet(
                        constraints: const BoxConstraints(maxWidth: 500),
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10.0)),
                        ),
                        isScrollControlled: true,
                        context: playerController
                            .homeScaffoldkey.currentState!.context,
                        //constraints: BoxConstraints(maxHeight:Get.height),
                        barrierColor: Colors.transparent.withAlpha(100),
                        builder: (context) => SongInfoBottomSheet(
                          items[index] as MediaItem,
                          playlist: playlist,
                        ),
                      ).whenComplete(() => Get.delete<SongInfoController>());
                    },
                    icon: const Icon(Icons.more_vert))
            ],
          ),
        ),
      ),
    );
  }

  Widget listViewPlaylists(List<dynamic> playlists, {ScrollController? sc}) {
    return Expanded(
      child: ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 210,
            top: 0,
          ),
          controller: sc,
          itemCount: playlists.length,
          itemExtent: 120,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => wideListTile(context,
              playlist: playlists[index],
              title: playlists[index].title,
              subtitle: playlists[index]?.description ?? "NA",
              subtitle2: "")),
    );
  }

  Widget listViewAlbums(List<dynamic> albums, {ScrollController? sc}) {
    return Expanded(
      child: ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 210,
            top: 0,
          ),
          controller: sc,
          itemCount: albums.length,
          itemExtent: 120,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            String artistName = "";
            for (dynamic items in (albums[index].artists).sublist(1)) {
              artistName = "${artistName + items['name']},";
            }
            artistName = artistName.length > 16
                ? artistName.substring(0, 16)
                : artistName;
            return wideListTile(context,
                album: albums[index],
                title: albums[index].title,
                subtitle: artistName,
                subtitle2:
                    "${(albums[index].artists[0]['name'])} • ${albums[index].year}");
          }),
    );
  }

  Widget listViewArtists(List<dynamic> artists, {ScrollController? sc}) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        bottom: 200,
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
              id: ScreenNavigationSetup.id, arguments: [false, artists[index]]);
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
    );
  }

  Widget wideListTile(BuildContext context,
      {dynamic album,
      dynamic playlist,
      required String title,
      required String subtitle,
      required String subtitle2}) {
    return InkWell(
      onTap: () {
        if (album != null) {
          Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
              id: ScreenNavigationSetup.id, arguments: [true, album, false]);
        } else {
          Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
              id: ScreenNavigationSetup.id,
              arguments: [false, playlist, false]);
        }
      },
      child: SizedBox(
        height: 120,
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
          child: Row(
            children: [
              ImageWidget(
                size: 100,
                album: album,
                playlist: playlist,
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      subtitle2,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
