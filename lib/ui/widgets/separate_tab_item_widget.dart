import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/Artists/artist_screen_controller.dart';
import '../screens/Search/search_result_screen_controller.dart';
import 'list_widget.dart';
import 'loader.dart';
import 'sort_widget.dart';

class SeparateTabItemWidget extends StatelessWidget {
  const SeparateTabItemWidget(
      {super.key,
      required this.items,
      required this.title,
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
    final artistController =
        Get.isRegistered<ArtistScreenController>(tag: artistControllerTag)
            ? Get.find<ArtistScreenController>(tag: artistControllerTag)
            : null;
    final searchResController = Get.isRegistered<SearchResultScreenController>()
        ? Get.find<SearchResultScreenController>()
        : null;
    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 5),
      child: Column(
        children: [
          if (!hideTitle)
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toLowerCase().removeAllWhitespace.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  isCompleteList
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: () {
                            searchResController!.viewAllCallback(title);
                          },
                          child: Text("viewAll".tr,
                              style:
                                  Theme.of(Get.context!).textTheme.titleSmall))
                ],
              ),
            ),
          isCompleteList
              ? Obx(() => SortWidget(
                    tag: "${title}_$artistControllerTag",
                    isSearchFeatureRequired: artistController != null,
                    titleLeftPadding: 9,
                    itemCountTitle:
                        "${isResultWidget ? (searchResController?.separatedResultContent[title] ?? []).length : (artistController?.sepataredContent[title] != null ? artistController?.sepataredContent[title]['results'] : []).length} ${"items".tr}",
                    isDurationOptionRequired:
                        title == "Songs" || title == "Videos",
                    isDateOptionRequired:
                        title == 'Albums' || title == "Singles",
                    onSort: (a, b, c, d) {
                      isResultWidget
                          ? searchResController!.onSort(a, b, c, d, title)
                          : artistController?.onSort(a, b, c, d, title);
                    },
                    onSearch: artistController?.onSearch,
                    onSearchClose: artistController?.onSearchClose,
                    onSearchStart: artistController?.onSearchStart,
                  ))
              : const SizedBox.shrink(),
          isCompleteList
              ? isResultWidget
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
                            child: Center(child: LoadingIndicator()));
                      }
                    })
                  : (artistController!.isArtistContentFetced.isTrue
                      ? ListWidget(
                          items,
                          title,
                          isCompleteList,
                          scrollController: scrollController,
                        )
                      : const Expanded(
                          child: Center(child: LoadingIndicator())))
              : ListWidget(
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
