import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/ui/screens/Search/search_screen_controller.dart';

import '../../../navigator.dart';

class SearchItem extends StatelessWidget {
  final String queryString;
  final bool isHistoryString;
  const SearchItem(
      {super.key, required this.queryString, required this.isHistoryString});

  @override
  Widget build(BuildContext context) {
    final searchScreenController = Get.find<SearchScreenController>();
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 10, right: 20),
      onTap: () {
        Get.toNamed(ScreenNavigationSetup.searchResultScreen,
            id: ScreenNavigationSetup.id, arguments: queryString);
        searchScreenController.addToHistryQueryList(queryString);
        // for Desktop searchbar
        if(GetPlatform.isDesktop){
          searchScreenController.focusNode.unfocus();
        }
      },
      leading: isHistoryString
          ? const Icon(Icons.history)
          : const Icon(Icons.search_rounded),
      minLeadingWidth: 20,
      dense: true,
      title: Text(queryString),
      trailing: SizedBox(
        width: 80,
        child: Row(
          children: [
            isHistoryString
                ? IconButton(
                    iconSize: 18,
                    splashRadius: 18,
                    visualDensity: const VisualDensity(horizontal: -2),
                    onPressed: () {
                      searchScreenController
                          .removeQueryFromHistory(queryString);
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).textTheme.titleMedium!.color,
                    ),
                  )
                : const SizedBox(
                    width: 40,
                  ),
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
          ],
        ),
      ),
    );
  }
}
