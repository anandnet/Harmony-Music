import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/ui/screens/Library/library_controller.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/content_list_widget_item.dart';
import 'package:harmonymusic/ui/widgets/list_widget.dart';
import 'package:harmonymusic/ui/widgets/modification_list.dart';
import 'package:harmonymusic/ui/widgets/piped_sync_widget.dart';
import 'package:harmonymusic/ui/widgets/sort_widget.dart';

class SongsLibraryWidget extends StatelessWidget {
  const SongsLibraryWidget({super.key, this.isBottomNavActive = false});

  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final topPadding = context.isLandscape ? 50.0 : 90.0;
    return Padding(
      padding: isBottomNavActive ? const EdgeInsets.only(left: 15) : EdgeInsets.only(left: 5, top: topPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBottomNavActive)
            const SizedBox(height: 10)
          else
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'libSongs'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                )),
          Obx(() {
            final libSongsController = Get.find<LibrarySongsController>();
            return SortWidget(
              tag: 'LibSongSort',
              itemCountTitle: '${libSongsController.librarySongsList.length}',
              itemIcon: Icons.music_note_rounded,
              titleLeftPadding: 9,
              requiredSortTypes: buildSortTypeSet(true, true),
              isSearchFeatureRequired: true,
              isSongDeletionFeatureRequired: true,
              onSort: (type, ascending) {
                libSongsController.onSort(type, ascending);
              },
              onSearch: libSongsController.onSearch,
              onSearchClose: libSongsController.onSearchClose,
              onSearchStart: libSongsController.onSearchStart,
              startAdditionalOperation: libSongsController.startAdditionalOperation,
              selectAll: libSongsController.selectAll,
              performAdditionalOperation: libSongsController.performAdditionalOperation,
              cancelAdditionalOperation: libSongsController.cancelAdditionalOperation,
            );
          }),
          GetX<LibrarySongsController>(builder: (controller) {
            return controller.librarySongsList.isNotEmpty
                ? (controller.additionalOperationMode.value == OperationMode.none
                    ? ListWidget(
                        controller.librarySongsList,
                        'library Songs',
                        true,
                        isPlaylist: true,
                        playlist: Playlist(
                            title: 'Library Songs', playlistId: 'SongsCache', thumbnailUrl: '', isCloudPlaylist: false),
                      )
                    : ModificationList(
                        mode: controller.additionalOperationMode.value,
                        librarySongsController: controller,
                      ))
                : Expanded(
                    child: Center(
                        child: Text(
                      'noOfflineSong'.tr,
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
                  );
          })
        ],
      ),
    );
  }
}

class PlaylistNAlbumLibraryWidget extends StatelessWidget {
  const PlaylistNAlbumLibraryWidget({super.key, this.isAlbumContent = true, this.isBottomNavActive = false});

  final bool isAlbumContent;
  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final libraryAlbumCtrl = Get.find<LibraryAlbumsController>();
    final libraryPlaylistCtrl = Get.find<LibraryPlaylistsController>();
    final settingsScreenCtrl = Get.find<SettingsScreenController>();
    final size = MediaQuery.of(context).size;

    const itemHeight = 180;
    const itemWidth = 130;
    final topPadding = context.isLandscape ? 50.0 : 90.0;

    return Padding(
        padding: isBottomNavActive ? const EdgeInsets.only(left: 15) : EdgeInsets.only(top: topPadding),
        child: column.children([
          padding.pl8.child(
            row.spaceBetween.children([
              if (isBottomNavActive)
                const SizedBox(height: 10)
              else
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isAlbumContent ? 'libAlbums'.tr : 'libPlaylists'.tr,
                      style: Theme.of(context).textTheme.titleLarge,
                    )),
              if (settingsScreenCtrl.isBottomNavBarEnabled.isTrue ||
                  isAlbumContent ||
                  settingsScreenCtrl.isLinkedWithPiped.isFalse)
                const SizedBox.shrink()
              else
                PipedSyncWidget(
                  padding: EdgeInsets.only(right: size.width * .05),
                )
            ]),
          ),
          Obx(
            () => isAlbumContent
                ? SortWidget(
                    tag: 'LibAlbumSort',
                    isAdditionalOperationRequired: false,
                    isSearchFeatureRequired: true,
                    itemCountTitle: "${libraryAlbumCtrl.libraryAlbums.length} ${"items".tr}",
                    requiredSortTypes: buildSortTypeSet(true),
                    onSort: (type, ascending) {
                      libraryAlbumCtrl.onSort(type, ascending);
                    },
                    onSearch: libraryAlbumCtrl.onSearch,
                    onSearchClose: libraryAlbumCtrl.onSearchClose,
                    onSearchStart: libraryAlbumCtrl.onSearchStart,
                  )
                : SortWidget(
                    tag: 'LibPlaylistSort',
                    isAdditionalOperationRequired: false,
                    isSearchFeatureRequired: true,
                    itemCountTitle: "${libraryPlaylistCtrl.libraryPlaylists.length} ${"items".tr}",
                    requiredSortTypes: buildSortTypeSet(),
                    onSort: (type, ascending) {
                      libraryPlaylistCtrl.onSort(type, ascending);
                    },
                    onSearch: libraryPlaylistCtrl.onSearch,
                    onSearchClose: libraryPlaylistCtrl.onSearchClose,
                    onSearchStart: libraryPlaylistCtrl.onSearchStart,
                  ),
          ),
          Expanded(
            child: Obx(
              () => (isAlbumContent
                      ? libraryAlbumCtrl.libraryAlbums.isNotEmpty
                      : libraryPlaylistCtrl.libraryPlaylists.isNotEmpty)
                  ? LayoutBuilder(builder: (context, constraints) {
                      //Fix for grid in mobile screen
                      final availableWidth =
                          constraints.maxWidth > 300 && constraints.maxWidth < 394 ? 310.0 : constraints.maxWidth;
                      var columns = (availableWidth / itemWidth).floor();
                      return SizedBox(
                        width: availableWidth,
                        child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              childAspectRatio: itemWidth / itemHeight,
                            ),
                            controller: ScrollController(keepScrollOffset: false),
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(bottom: 200, top: 10),
                            itemCount: isAlbumContent
                                ? libraryAlbumCtrl.libraryAlbums.length
                                : libraryPlaylistCtrl.libraryPlaylists.length,
                            itemBuilder: (context, index) => Center(
                                  child: ContentListItem(
                                    content: isAlbumContent
                                        ? libraryAlbumCtrl.libraryAlbums[index]
                                        : libraryPlaylistCtrl.libraryPlaylists[index],
                                    isLibraryItem: true,
                                  ),
                                )),
                      );
                    })
                  : Center(
                      child: Text(
                      'noBookmarks'.tr,
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
            ),
          )
        ]));
  }
}

class LibraryArtistWidget extends StatelessWidget {
  const LibraryArtistWidget({super.key, this.isBottomNavActive = false});

  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final cntrller = Get.find<LibraryArtistsController>();
    final topPadding = context.isLandscape ? 50.0 : 90.0;
    return Padding(
      padding: isBottomNavActive ? const EdgeInsets.only(left: 15) : EdgeInsets.only(left: 5, top: topPadding),
      child: Column(
        children: [
          if (isBottomNavActive)
            const SizedBox(height: 10)
          else
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'libArtists'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                )),
          Obx(
            () => SortWidget(
              tag: 'LibArtistSort',
              isAdditionalOperationRequired: false,
              isSearchFeatureRequired: true,
              itemCountTitle: "${cntrller.libraryArtists.length} ${"items".tr}",
              onSort: (type, ascending) {
                cntrller.onSort(type, ascending);
              },
              onSearch: cntrller.onSearch,
              onSearchClose: cntrller.onSearchClose,
              onSearchStart: cntrller.onSearchStart,
            ),
          ),
          Obx(() => cntrller.libraryArtists.isNotEmpty
              ? ListWidget(cntrller.libraryArtists, 'Library Artists', true)
              : Expanded(
                  child: Center(
                      child: Text(
                  'noBookmarks'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ))))
        ],
      ),
    );
  }
}
