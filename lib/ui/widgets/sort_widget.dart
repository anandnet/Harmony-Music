// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum OperationMode { arrange, delete, addToPlaylist, none }

enum SortType {
  Name,
  Date,
  Duration,
  RecentlyPlayed,
}

Set<SortType> buildSortTypeSet([bool dateRequired = false, bool durationRequired = false, bool recentlyPlayedRequired = false]) {
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
  final Function(SortWidgetController, OperationMode)? startAdditionalOperation;
  final Function(bool)? selectAll;
  final Function()? performAdditionalOperation;
  final Function()? cancelAdditionalOperation;
  final Function(String?)? onSearchStart;
  final Function(String, String?)? onSearch;
  final Function(String?)? onSearchClose;
  final Function(SortType, bool) onSort;

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
                        Icons.music_note_rounded,
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
                  icon: const Icon(Icons.sort_by_alpha_rounded),
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
                        icon: const Icon(Icons.calendar_month_rounded),
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
                        icon: const Icon(Icons.timer_rounded),
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
                      ? const Icon(Icons.arrow_downward_rounded)
                      : const Icon(Icons.arrow_upward_rounded),
                  iconSize: 20,
                  splashRadius: 20,
                  visualDensity:
                      const VisualDensity(horizontal: -3, vertical: -3),
                  onPressed: () {
                    controller.onAscendNDescend(onSort);
                  },
                ),
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
                    Icons.more_vert_rounded,
                    size: 20,
                  ),
                  // Callback that sets the selected popup menu item.
                  onSelected: (mode) {
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
              child: TextField(
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
          if (controller.isDeletionEnabled.isTrue ||
              controller.isAddtoPlaylistEnabled.isTrue)
            Container(
              height: 35,
              color: Theme.of(context).canvasColor,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Obx(
                          () => Checkbox(
                            value: controller.isAllSelected.value,
                            onChanged: (val) {
                              selectAll!(val!);
                              controller.toggleSelectAll(val);
                            },
                            visualDensity: const VisualDensity(
                                horizontal: -3, vertical: -3),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Text("Select all")
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(controller.isAddtoPlaylistEnabled.isTrue
                            ? Icons.add_circle_outline_rounded
                            : Icons.delete),
                        iconSize: 20,
                        splashRadius: 18,
                        visualDensity:
                            const VisualDensity(horizontal: -3, vertical: -3),
                        onPressed: () {
                          performAdditionalOperation!();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        splashRadius: 18,
                        visualDensity:
                            const VisualDensity(horizontal: -3, vertical: -3),
                        onPressed: () {
                          controller.setActiveMode(OperationMode.none);
                          cancelAdditionalOperation!();
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  )
                ],
              ),
            ),
          if (controller.isRearraningEnabled.isTrue)
            Container(
              height: 35,
              color: Theme.of(context).canvasColor,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    iconSize: 20,
                    splashRadius: 18,
                    visualDensity:
                        const VisualDensity(horizontal: -3, vertical: -3),
                    onPressed: () {
                      performAdditionalOperation!();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    splashRadius: 18,
                    visualDensity:
                        const VisualDensity(horizontal: -3, vertical: -3),
                    onPressed: () {
                      controller.setActiveMode(OperationMode.none);
                      cancelAdditionalOperation!();
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            )
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
