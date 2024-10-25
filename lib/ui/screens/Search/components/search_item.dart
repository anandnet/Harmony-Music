import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/screens/Search/search_screen_controller.dart';

class SearchItem extends StatelessWidget {
  final String queryString;
  final bool isHistoryString;

  const SearchItem({
    required this.queryString,
    required this.isHistoryString,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final searchScreenController = Get.find<SearchScreenController>();
    return ListTile(
        contentPadding: const EdgeInsets.only(left: 10, right: 20),
        onTap: () {
          Get.toNamed(
            ScreenNavigationSetup.searchResultScreen,
            id: ScreenNavigationSetup.id,
            arguments: queryString,
          );
          searchScreenController.addToHistoryQueryList(queryString);
          // for Desktop searchbar
          if (GetPlatform.isDesktop) {
            searchScreenController.focusNode.unfocus();
          }
        },
        leading: isHistoryString ? Icons.history.icon.mk : Icons.search_rounded.icon.mk,
        minLeadingWidth: 20,
        dense: true,
        title: queryString.text.mk,
        trailing: sizedBox.w160.child(
          row.children([
            if (isHistoryString)
              IconButton(
                iconSize: 18,
                splashRadius: 18,
                visualDensity: const VisualDensity(horizontal: -2),
                onPressed: () {
                  searchScreenController.removeQueryFromHistory(queryString);
                },
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context).textTheme.titleMedium!.color,
                ),
              )
            else
              const SizedBox(width: 40),
            IconButton(
              iconSize: 20,
              splashRadius: 18,
              visualDensity: const VisualDensity(horizontal: -2),
              onPressed: () {
                searchScreenController.suggestionInput(queryString);
              },
              icon: Icon(
                Icons.north_west,
                color: Theme.of(context).textTheme.titleMedium!.color,
              ),
            ),
          ]),
        ));
  }
}
