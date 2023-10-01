import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SortWidget extends StatelessWidget {
  const SortWidget({
    super.key,
    required this.tag,
    this.itemCountTitle = '',
    this.titleLeftPadding = 18,
    this.isDateOptionRequired = false,
    this.isDurationOptionRequired = false,
    this.isSearchFeatureRequired = false,
    this.onSearchStart,
    this.onSearch,
    this.onSearchClose,
    required this.onSort,
  });

  /// unique identifier for each sortwidget
  final String tag;
  final String itemCountTitle;
  final double titleLeftPadding;
  final bool isDurationOptionRequired;
  final bool isDateOptionRequired;
  final bool isSearchFeatureRequired;
  final Function(String?)? onSearchStart;
  final Function(String,String?)? onSearch;
  final Function(String?)? onSearchClose;
  final Function(bool, bool, bool, bool) onSort;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SortWidgetController(), tag: tag);
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: titleLeftPadding),
              child: Text(itemCountTitle),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(
                  () => IconButton(
                    color: controller.sortByName.value
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
                isDateOptionRequired
                    ? Obx(() => IconButton(
                          color: controller.sortByDate.value
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
                isDurationOptionRequired
                    ? Obx(() => IconButton(
                          color: controller.sortByDuration.value
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
                const SizedBox(
                  width: 40,
                ),
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
                const SizedBox(
                  width: 20,
                )
              ],
            ),
          ],
        ),
        Obx(() => controller.isSearchingEnabled.value
            ? Container(
                height: 60,
                padding: const EdgeInsets.only(
                    top: 15, bottom: 5, left: 5, right: 20),
                color: Theme.of(context).canvasColor,
                child: TextField(
                  controller: controller.textEditingController,
                  textAlignVertical: TextAlignVertical.center,
                  autofocus: true,
                  onChanged: (value) {
                    onSearch!(value,tag);
                  },
                  cursorColor: Theme.of(context).textTheme.titleSmall!.color,
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(8),
                      filled: true,
                      border: const OutlineInputBorder(),
                      hintText: "Search term",
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
              )
            : const SizedBox.shrink())
      ],
    );
  }
}

class SortWidgetController extends GetxController {
  final sortByName = true.obs;
  final isAscending = true.obs;
  final sortByDate = false.obs;
  final sortByDuration = false.obs;
  final isSearchingEnabled = false.obs;
  TextEditingController textEditingController = TextEditingController();

  void onSortByName(Function onSort) {
    sortByName.value = true;
    sortByDate.value = false;
    sortByDuration.value = false;
    onSort(sortByName.value, sortByDate.value, sortByDuration.value,
        isAscending.value);
  }

  void onSortByDuration(Function onSort) {
    sortByName.value = false;
    sortByDate.value = false;
    sortByDuration.value = true;
    onSort(sortByName.value, sortByDate.value, sortByDuration.value,
        isAscending.value);
  }

  void onSortByDate(Function onSort) {
    sortByName.value = false;
    sortByDate.value = true;
    sortByDuration.value = false;
    onSort(sortByName.value, sortByDate.value, sortByDuration.value,
        isAscending.value);
  }

  void onAscendNDescend(Function onSort) {
    isAscending.value = !isAscending.value;
    onSort(sortByName.value, sortByDate.value, sortByDuration.value,
        isAscending.value);
  }

  void toggleSearch() {
    isSearchingEnabled.value = !isSearchingEnabled.value;
  }
}
