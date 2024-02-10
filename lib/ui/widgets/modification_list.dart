import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/screens/Artists/artist_screen_controller.dart';
import '/ui/screens/Library/library_controller.dart';
import '/ui/screens/PlaylistNAlbum/playlistnalbum_screen_controller.dart';
import '/ui/widgets/sort_widget.dart' show OperationMode;
import 'image_widget.dart';
import 'marqwee_widget.dart';

class ModificationList extends StatelessWidget {
  const ModificationList(
      {super.key,
      required this.mode,
      this.librarySongsController,
      this.playListNAlbumScreenController,this.artistScreenController});
  final OperationMode mode;
  final PlayListNAlbumScreenController? playListNAlbumScreenController;
  final LibrarySongsController? librarySongsController;
  final ArtistScreenController? artistScreenController;

  @override
  Widget build(BuildContext context) {
    dynamic controller = librarySongsController ?? playListNAlbumScreenController ?? artistScreenController;
    final items = controller!.additionalOperationTempList;
    if (mode == OperationMode.arrange) {
      return Expanded(
        child: ReorderableListView.builder(
            padding: const EdgeInsets.only(right: 5, bottom: 200),
            itemBuilder: (context, index) => ListTile(
                  key: Key('$index'),
                  onTap: () {},
                  contentPadding:
                      const EdgeInsets.only(top: 0, left: 5, right: 40),
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
                ),
            itemCount: items.length,
            onReorder: (old_, new_) {
              if (old_ < new_) {
                new_--;
              }
              final list = items.toList();
              final item = list.removeAt(
                old_,
              );
              list.insert(new_, item);
              controller.additionalOperationTempList.value = list;
            }),
      );
    } else if (mode == OperationMode.addToPlaylist ||
        mode == OperationMode.delete) {
      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.only(right: 5, bottom: 200),
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            onTap: () {
              controller.additionalOperationTempMap[index] = !controller.additionalOperationTempMap[index]!;
              controller.checkIfAllSelected();
            },
            contentPadding: const EdgeInsets.only(top: 0, left: 5, right: 30),
            leading: SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.additionalOperationTempMap[index],
                      onChanged: (val) {
                        controller.additionalOperationTempMap[index] =
                            val!;
                        controller.checkIfAllSelected();
                      },
                      visualDensity:
                          const VisualDensity(horizontal: -3, vertical: -3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  ImageWidget(
                    size: 55,
                    song: items[index],
                  ),
                ],
              ),
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
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
