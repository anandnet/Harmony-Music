// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Library/library_controller.dart';

import 'additional_operation_dialog.dart';
import 'modified_text_field.dart';

enum OperationMode { arrange, delete, addToPlaylist, none }

enum SortType {
  Name,
  Date,
  Duration,
  RecentlyPlayed,
}

Set<SortType> buildSortTypeSet(
    [bool dateRequired = false,
    bool durationRequired = false,
    bool recentlyPlayedRequired = false]) {
  Set<SortType> requiredSortTypes = {};
  if (dateRequired) {
    requiredSortTypes.add(SortType.Date);
  }
  if (durationRequired) {
    requiredSortTypes.add(SortType.Duration);
  }
  if (recentlyPlayedRequired) {
    requiredSortTypes.add(SortType.RecentlyPlayed);
  }
  return requiredSortTypes;
}

class SortWidget extends StatelessWidget {
  /// Additional operations - Delete Multiple songs, Rearrage offline playlist, Add Multiple songs to playlist
  const SortWidget({
    super.key,
    required this.tag,
    this.itemCountTitle = '',
    this.titleLeftPadding = 18,
    this.isAdditionalOperationRequired = true,
    this.requiredSortTypes = const <SortType>{SortType.Name},
    this.isSearchFeatureRequired = false,
    this.isPlaylistRearrageFeatureRequired = false,
    this.isSongDeletetioFeatureRequired = false,
    required this.screenController,
    this.onSearchStart,
    this.onSearch,
    this.onSearchClose,
    this.itemIcon,
    this.startAdditionalOperation,
    this.selectAll,
    this.performAdditionalOperation,
    this.cancelAdditionalOperation,
    required this.onSort,
  });

  /// unique identifier for each sortwidget
  final String tag;
  final String itemCountTitle;
  final IconData? itemIcon;
  final bool isAdditionalOperationRequired;
  final double titleLeftPadding;
  final Set<SortType> requiredSortTypes;
  final bool isSearchFeatureRequired;
  final bool isSongDeletetioFeatureRequired;
  final bool isPlaylistRearrageFeatureRequired;
  final dynamic screenController;
  final Function(SortWidgetController, OperationMode)? startAdditionalOperation;
  final Function(bool)? selectAll;
  final Function()? performAdditionalOperation;
  final Function()? cancelAdditionalOperation;
  final Function(String?)? onSearchStart;
  final Function(String, String?)? onSearch;
  final Function(String?)? onSearchClose;
  final Function(SortType, bool) onSort;

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "importPlaylist".tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "importPlaylistDesc".tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              "importLargeFileNote".tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.file_open),
                label: Text("selectFile".tr),
                onPressed: () {
                  Get.find<LibraryPlaylistsController>()
                      .importPlaylistFromJson(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text("close".tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SortWidgetController(), tag: tag);
    return Obx(
      () => Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(left: titleLeftPadding),
                child: Row(
                  children: [
                    Text(itemCountTitle),
                    if (itemIcon != null)
                      Icon(
                        Icons.music_note,
                        size: 15,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                  ],
                ),
              ),
              Obx(
                () => IconButton(
                  color: controller.sortType.value == SortType.Name
                      ? Theme.of(context).textTheme.bodySmall!.color
                      : Theme.of(context).colorScheme.secondary,
                  icon: const Icon(Icons.sort_by_alpha),
                  iconSize: 20,
                  splashRadius: 20,
                  visualDensity:
                      const VisualDensity(horizontal: -3, vertical: -3),
                  onPressed: () {
                    controller.onSortByName(onSort);
                  },
                ),
              ),
              requiredSortTypes.contains(SortType.Date)
                  ? Obx(() => IconButton(
                        color: controller.sortType.value == SortType.Date
                            ? Theme.of(context).textTheme.bodySmall!.color
                            : Theme.of(context).colorScheme.secondary,
                        icon: const Icon(Icons.calendar_month),
                        iconSize: 20,
                        splashRadius: 20,
                        visualDensity:
                            const VisualDensity(horizontal: -3, vertical: -3),
                        onPressed: () {
                          controller.onSortByDate(onSort);
                        },
                      ))
                  : const SizedBox.shrink(),
              requiredSortTypes.contains(SortType.Duration)
                  ? Obx(() => IconButton(
                        color: controller.sortType.value == SortType.Duration
                            ? Theme.of(context).textTheme.bodySmall!.color
                            : Theme.of(context).colorScheme.secondary,
                        icon: const Icon(Icons.timer),
                        iconSize: 20,
                        splashRadius: 20,
                        visualDensity:
                            const VisualDensity(horizontal: -3, vertical: -3),
                        onPressed: () {
                          controller.onSortByDuration(onSort);
                        },
                      ))
                  : const SizedBox.shrink(),
              const Expanded(child: SizedBox()),
              Obx(
                () => IconButton(
                  icon: controller.isAscending.value
                      ? const Icon(Icons.arrow_downward)
                      : const Icon(Icons.arrow_upward),
                  iconSize: 20,
                  splashRadius: 20,
                  visualDensity:
                      const VisualDensity(horizontal: -3, vertical: -3),
                  onPressed: () {
                    controller.onAscendNDescend(onSort);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.import_contacts),
                tooltip: "importPlaylist".tr,
                onPressed: () => _showImportDialog(context),
              ),
              if (isSearchFeatureRequired)
                IconButton(
                  icon: const Icon(Icons.search),
                  iconSize: 20,
                  splashRadius: 20,
                  visualDensity:
                      const VisualDensity(horizontal: -3, vertical: -3),
                  onPressed: () {
                    onSearchStart!(tag);
                    controller.toggleSearch();
                  },
                ),
              if (isAdditionalOperationRequired)
                PopupMenuButton(
                  child: const Icon(
                    Icons.more_vert,
                    size: 20,
                  ),
                  // Callback that sets the selected popup menu item.
                  onSelected: (mode) {
                    showDialog(
                        context: context,
                        builder: (context) => AdditionalOperationDialog(
                              operationMode: mode,
                              screenController: screenController,
                              controller: controller,
                            ));

                    controller.setActiveMode(mode);
                    startAdditionalOperation!(controller, mode);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    if (isPlaylistRearrageFeatureRequired)
                      PopupMenuItem(
                        value: OperationMode.arrange,
                        child: Text("reArrangePlaylist".tr),
                      ),
                    if (isSongDeletetioFeatureRequired)
                      PopupMenuItem(
                        value: OperationMode.delete,
                        child: Text("removeMultiple".tr),
                      ),
                    PopupMenuItem(
                      value: OperationMode.addToPlaylist,
                      child: Text("addMultipleSongs".tr),
                    ),
                  ],
                ),
              const SizedBox(
                width: 15,
              )
            ],
          ),
          if (controller.isSearchingEnabled.value)
            Container(
              height: 60,
              padding:
                  const EdgeInsets.only(top: 15, bottom: 5, left: 5, right: 20),
              color: Theme.of(context).canvasColor,
              child: ModifiedTextField(
                controller: controller.textEditingController,
                textAlignVertical: TextAlignVertical.center,
                autofocus: true,
                onChanged: (value) {
                  onSearch!(value, tag);
                },
                cursorColor: Theme.of(context).textTheme.titleSmall!.color,
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.all(8),
                    filled: true,
                    border: const OutlineInputBorder(),
                    hintText: "search".tr,
                    suffixIconColor: Theme.of(context).colorScheme.secondary,
                    suffixIcon: IconButton(
                      splashRadius: 10,
                      iconSize: 20,
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        controller.toggleSearch();
                        onSearchClose!(tag);
                      },
                    )),
              ),
            ),
        ],
      ),
    );
  }
}

class SortWidgetController extends GetxController {
  final Rx<SortType> sortType = SortType.Name.obs;
  final isAscending = true.obs;
  final isSearchingEnabled = false.obs;
  final isRearraningEnabled = false.obs;
  final isDeletionEnabled = false.obs;
  final isAddtoPlaylistEnabled = false.obs;
  final isAllSelected = false.obs;
  TextEditingController textEditingController = TextEditingController();

  void setActiveMode(OperationMode mode) {
    isAddtoPlaylistEnabled.value = OperationMode.addToPlaylist == mode;
    isDeletionEnabled.value = OperationMode.delete == mode;
    isRearraningEnabled.value = OperationMode.arrange == mode;
  }

  void toggleSelectAll(bool val) {
    isAllSelected.value = val;
  }

  void onSortByName(Function onSort) {
    sortType.value = SortType.Name;
    onSort(sortType.value, isAscending.value);
  }

  void onSortByDuration(Function onSort) {
    sortType.value = SortType.Duration;
    onSort(sortType.value, isAscending.value);
  }

  void onSortByDate(Function onSort) {
    sortType.value = SortType.Date;
    onSort(sortType.value, isAscending.value);
  }

  void onAscendNDescend(Function onSort) {
    isAscending.value = !isAscending.value;
    onSort(sortType.value, isAscending.value);
  }

  void toggleSearch() {
    isSearchingEnabled.value = !isSearchingEnabled.value;
  }
}
