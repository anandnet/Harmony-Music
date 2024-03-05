import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/widgets/modification_list.dart';
import '../../../models/playlist.dart';
import '../../widgets/piped_sync_widget.dart';
import 'library_controller.dart';
import '../../widgets/content_list_widget_item.dart';
import '../../widgets/list_widget.dart';
import '../../widgets/sort_widget.dart';
import '../Settings/settings_screen_controller.dart';

class SongsLibraryWidget extends StatelessWidget {
  const SongsLibraryWidget({super.key, this.isBottomNavActive = false});
  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isBottomNavActive
          ? const EdgeInsets.only(left: 15)
          : const EdgeInsets.only(left: 5.0, top: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isBottomNavActive
              ? const SizedBox(
                  height: 10,
                )
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "libSongs".tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
          Obx(() {
            final libSongsController = Get.find<LibrarySongsController>();
            return SortWidget(
              tag: "LibSongSort",
              itemCountTitle: "${libSongsController.librarySongsList.length}",
              itemIcon: Icons.music_note_rounded,
              titleLeftPadding: 9,
              requiredSortTypes: buildSortTypeSet(true, true),
              isSearchFeatureRequired: true,
              isSongDeletetioFeatureRequired: true,
              onSort: (type, ascending) {
                libSongsController.onSort(type, ascending);
              },
              onSearch: libSongsController.onSearch,
              onSearchClose: libSongsController.onSearchClose,
              onSearchStart: libSongsController.onSearchStart,
              startAdditionalOperation:
                  libSongsController.startAdditionalOperation,
              selectAll: libSongsController.selectAll,
              performAdditionalOperation:
                  libSongsController.performAdditionalOperation,
              cancelAdditionalOperation:
                  libSongsController.cancelAdditionalOperation,
            );
          }),
          GetX<LibrarySongsController>(builder: (controller) {
            return controller.librarySongsList.isNotEmpty
                ? (controller.additionalOperationMode.value ==
                        OperationMode.none
                    ? ListWidget(
                        controller.librarySongsList,
                        "library Songs",
                        true,
                        isPlaylist: true,
                        playlist: Playlist(
                            title: "Library Songs",
                            playlistId: "SongsCache",
                            thumbnailUrl: "",
                            isCloudPlaylist: false),
                      )
                    : ModificationList(
                        mode: controller.additionalOperationMode.value,
                        librarySongsController: controller,
                      ))
                : Expanded(
                    child: Center(
                        child: Text(
                      "noOfflineSong".tr,
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
  const PlaylistNAlbumLibraryWidget(
      {super.key, this.isAlbumContent = true, this.isBottomNavActive = false});
  final bool isAlbumContent;
  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final libralbumCntrller = Get.find<LibraryAlbumsController>();
    final librplstCntrller = Get.find<LibraryPlaylistsController>();
    final settingscrnController = Get.find<SettingsScreenController>();
    var size = MediaQuery.of(context).size;

    const double itemHeight = 220;
    const double itemWidth = 180;

    return Padding(
      padding: isBottomNavActive
          ? const EdgeInsets.only(left: 15)
          : const EdgeInsets.only(top: 90.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isBottomNavActive
                    ? const SizedBox(
                        height: 10,
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isAlbumContent ? "libAlbums".tr : "libPlaylists".tr,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                (settingscrnController.isBottomNavBarEnabled.isTrue ||
                        isAlbumContent ||
                        settingscrnController.isLinkedWithPiped.isFalse)
                    ? const SizedBox.shrink()
                    : PipedSyncWidget(
                        padding: EdgeInsets.only(right: size.width * .05),
                      )
              ],
            ),
          ),
          Obx(
            () => isAlbumContent
                ? SortWidget(
                    tag: "LibAlbumSort",
                    isAdditionalOperationRequired: false,
                    isSearchFeatureRequired: true,
                    itemCountTitle:
                        "${libralbumCntrller.libraryAlbums.length} ${"items".tr}",
                    requiredSortTypes: buildSortTypeSet(true),
                    onSort: (type, ascending) {
                      libralbumCntrller.onSort(type, ascending);
                    },
                    onSearch: libralbumCntrller.onSearch,
                    onSearchClose: libralbumCntrller.onSearchClose,
                    onSearchStart: libralbumCntrller.onSearchStart,
                  )
                : SortWidget(
                    tag: "LibPlaylistSort",
                    isAdditionalOperationRequired: false,
                    isSearchFeatureRequired: true,
                    itemCountTitle:
                        "${librplstCntrller.libraryPlaylists.length} ${"items".tr}",
                    requiredSortTypes: buildSortTypeSet(),
                    onSort: (type, ascending) {
                      librplstCntrller.onSort(type, ascending);
                    },
                    onSearch: librplstCntrller.onSearch,
                    onSearchClose: librplstCntrller.onSearchClose,
                    onSearchStart: librplstCntrller.onSearchStart,
                  ),
          ),
          Expanded(
            child: Obx(
              () => (isAlbumContent
                      ? libralbumCntrller.libraryAlbums.isNotEmpty
                      : librplstCntrller.libraryPlaylists.isNotEmpty)
                  ? GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ((size.width - 60) / itemWidth).ceil(),
                        childAspectRatio: (itemWidth / itemHeight),
                      ),
                      controller: ScrollController(keepScrollOffset: false),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.only(bottom: 200, top: 10),
                      itemCount: isAlbumContent
                          ? libralbumCntrller.libraryAlbums.length
                          : librplstCntrller.libraryPlaylists.length,
                      itemBuilder: (context, index) => Center(
                            child: ContentListItem(
                              content: isAlbumContent
                                  ? libralbumCntrller.libraryAlbums[index]
                                  : librplstCntrller.libraryPlaylists[index],
                              isLibraryItem: true,
                            ),
                          ))
                  : Center(
                      child: Text(
                      "noBookmarks".tr,
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
            ),
          )
        ],
      ),
    );
  }
}

class LibraryArtistWidget extends StatelessWidget {
  const LibraryArtistWidget({super.key, this.isBottomNavActive = false});
  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final cntrller = Get.find<LibraryArtistsController>();
    return Padding(
      padding: isBottomNavActive
          ? const EdgeInsets.only(left: 15)
          : const EdgeInsets.only(left: 5, top: 90.0),
      child: Column(
        children: [
          isBottomNavActive
              ? const SizedBox(
                  height: 10,
                )
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "libArtists".tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
          Obx(
            () => SortWidget(
              tag: "LibArtistSort",
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
              ? ListWidget(cntrller.libraryArtists, "Library Artists", true)
              : Expanded(
                  child: Center(
                      child: Text(
                  "noBookmarks".tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ))))
        ],
      ),
    );
  }
}
