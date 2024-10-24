import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Artists/artist_screen_controller.dart';
import 'package:harmonymusic/ui/screens/Search/search_result_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/list_widget.dart';
import 'package:harmonymusic/ui/widgets/loader.dart';
import 'package:harmonymusic/ui/widgets/modification_list.dart';
import 'package:harmonymusic/ui/widgets/sort_widget.dart';

class SeparateTabItemWidget extends StatelessWidget {
  const SeparateTabItemWidget(
      {required this.items,
      required this.title,
      super.key,
      this.isCompleteList = true,
      this.isResultWidget = true,
      this.hideTitle = false,
      this.topPadding = 0,
      this.scrollController,
      this.artistControllerTag});

  /// tag for accessing Artist controller inst, [artistControllerTag] only valid for Artist screen
  final String? artistControllerTag;
  final List<dynamic> items;
  final String title;
  final bool isCompleteList;
  final double topPadding;
  final bool isResultWidget;
  final bool hideTitle;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final artistController = Get.isRegistered<ArtistScreenController>(tag: artistControllerTag)
        ? Get.find<ArtistScreenController>(tag: artistControllerTag)
        : null;
    final searchResController =
        Get.isRegistered<SearchResultScreenController>() ? Get.find<SearchResultScreenController>() : null;
    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 5),
      child: Column(
        children: [
          if (!hideTitle)
            sizedBox.h56.child(
              row.spaceBetween.children([
                Text(
                  title.toLowerCase().removeAllWhitespace.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (isCompleteList)
                  const SizedBox.shrink()
                else
                  TextButton(
                    onPressed: () {
                      searchResController!.viewAllCallback(title);
                    },
                    child: Text(
                      'viewAll'.tr,
                      style: Theme.of(Get.context!).textTheme.titleSmall,
                    ),
                  )
              ]),
            ),
          if (isCompleteList)
            Obx(() => SortWidget(
                  tag: '${title}_$artistControllerTag',
                  isAdditionalOperationRequired: artistController != null && (title == 'Songs' || title == 'Videos'),
                  isSearchFeatureRequired: artistController != null,
                  titleLeftPadding: 9,
                  itemCountTitle:
                      "${isResultWidget ? (searchResController?.separatedResultContent[title] ?? []).length : (artistController?.sepataredContent[title] != null ? artistController?.sepataredContent[title]['results'] : []).length} ${"items".tr}",
                  requiredSortTypes:
                      buildSortTypeSet(title == 'Albums' || title == 'Singles', title == 'Songs' || title == 'Videos'),
                  onSort: (type, ascending) {
                    isResultWidget
                        ? searchResController!.onSort(type, ascending, title)
                        : artistController?.onSort(type, ascending, title);
                  },
                  onSearch: artistController?.onSearch,
                  onSearchClose: artistController?.onSearchClose,
                  onSearchStart: artistController?.onSearchStart,
                  startAdditionalOperation: artistController?.startAdditionalOperation,
                  selectAll: artistController?.selectAll,
                  performAdditionalOperation: artistController?.performAdditionalOperation,
                  cancelAdditionalOperation: artistController?.cancelAdditionalOperation,
                ))
          else
            const SizedBox.shrink(),
          if (isCompleteList)
            isResultWidget
                ? GetX<SearchResultScreenController>(builder: (controller) {
                    if (controller.isSeparatedResultContentFetced.isTrue) {
                      return ListWidget(
                        controller.separatedResultContent[title],
                        title,
                        isCompleteList,
                        scrollController: scrollController,
                      );
                    } else {
                      return const Expanded(
                        child: Center(child: LoadingIndicator()),
                      );
                    }
                  })
                : (artistController!.isArtistContentFetced.isTrue
                    ? Obx(
                        () => (artistController.additionalOperationMode.value == OperationMode.none
                            ? ListWidget(
                                items,
                                title,
                                isCompleteList,
                                isArtistSongs: true,
                                scrollController: scrollController,
                              )
                            : ModificationList(
                                mode: artistController.additionalOperationMode.value,
                                artistScreenController: artistController,
                              )),
                      )
                    : const Expanded(child: Center(child: LoadingIndicator())))
          else
            ListWidget(
              items,
              title,
              isCompleteList,
              scrollController: scrollController,
            ),
        ],
      ),
    );
  }
}
