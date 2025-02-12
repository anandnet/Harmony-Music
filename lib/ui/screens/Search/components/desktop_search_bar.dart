import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'search_item.dart';
import '/ui/screens/Search/search_screen_controller.dart';

import '../../../navigator.dart';

class DesktopSearchBar extends StatelessWidget {
  const DesktopSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final searchScreenController = Get.find<SearchScreenController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.space):
                const DoNothingAndStopPropagationTextIntent()
          },
          child: SearchBar(
            controller: searchScreenController.textInputController,
            onTapOutside: (event) {},
            onChanged: searchScreenController.onChanged,
            onSubmitted: (val) {
              if (val.contains("https://")) {
                searchScreenController.filterLinks(Uri.parse(val));
                searchScreenController.reset();
                return;
              }
              Get.toNamed(ScreenNavigationSetup.searchResultScreen,
                  id: ScreenNavigationSetup.id, arguments: val);
              searchScreenController.addToHistryQueryList(val);
              searchScreenController.focusNode.unfocus();
            },
            focusNode: searchScreenController.focusNode,
            backgroundColor: WidgetStatePropertyAll<Color>(
                Theme.of(context).colorScheme.secondary),
            hintText: "searchDes".tr,
            leading: IconButton(
                onPressed: () {
                  if (searchScreenController.focusNode.hasFocus) {
                    searchScreenController.focusNode.unfocus();
                  }
                },
                icon: Obx(() => Icon(
                    searchScreenController.isSearchBarInFocus.isTrue
                        ? Icons.arrow_back
                        : Icons.search))),
            trailing: [
              Obx(() => searchScreenController.isSearchBarInFocus.isTrue
                  ? IconButton(
                      onPressed: searchScreenController.reset,
                      icon: const Icon(Icons.clear))
                  : const SizedBox.shrink())
            ],
            padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
                EdgeInsets.only(left: 15, right: 15)),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20)),
              constraints: const BoxConstraints(minHeight: 0, maxHeight: 300),
              child: Obx(() {
                final isHistoryString =
                    searchScreenController.textInputController.text.isEmpty &&
                        searchScreenController.suggestionList.isEmpty;
                final listToShow = isHistoryString
                    ? searchScreenController.historyQuerylist
                    : searchScreenController.suggestionList;
                return searchScreenController.urlPasted.isTrue
                    ? InkWell(
                        onTap: () {
                          searchScreenController.filterLinks(Uri.parse(
                              searchScreenController.textInputController.text));
                          searchScreenController.reset();
                        },
                        child: SizedBox(
                          width: double.maxFinite,
                          height: 50,
                          child: Center(
                              child: Text(
                            "urlSearchDes".tr,
                            style: Theme.of(context).textTheme.titleMedium,
                          )),
                        ),
                      )
                    : searchScreenController.isSearchBarInFocus.isTrue &&
                            listToShow.isNotEmpty
                        ? ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(5.0),
                            children: listToShow.map((item) {
                              return SearchItem(
                                  queryString: item,
                                  isHistoryString: isHistoryString);
                            }).toList())
                        : const SizedBox.shrink();
              }),
            ))
      ],
    );
  }
}
