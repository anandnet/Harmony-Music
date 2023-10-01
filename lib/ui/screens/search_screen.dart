import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/navigator.dart';
import '/ui/screens/search_screen_controller.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchScreenController = Get.put(SearchScreenController());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          Container(
            width: 60,
            color: Theme.of(context).navigationRailTheme.backgroundColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Theme.of(context).textTheme.titleMedium!.color,
                    ),
                    onPressed: () {
                      Get.nestedKey(ScreenNavigationSetup.id)!
                          .currentState!
                          .pop();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 90, left: 5),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Search",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: searchScreenController.textInputController,
                    textInputAction: TextInputAction.search,
                    onChanged: searchScreenController.onChanged,
                    onSubmitted: (val) {
                      Get.toNamed(ScreenNavigationSetup.searchResultScreen,
                          id: ScreenNavigationSetup.id, arguments: val);
                    },
                    autofocus: true,
                    cursorColor: Theme.of(context).textTheme.bodySmall!.color,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 5),
                      focusColor: Colors.white,
                      hintText: 'Songs,Playlist,Album or Artist',
                    ),
                  ),
                  Expanded(
                      child: Obx(() => ListView.builder(
                            padding: const EdgeInsets.only(top: 5),
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            itemCount:
                                searchScreenController.suggestionList.length,
                            itemBuilder: (context, index) => ListTile(
                              contentPadding:
                                  const EdgeInsets.only(left: 10, right: 20),
                              onTap: () {
                                Get.toNamed(
                                    ScreenNavigationSetup.searchResultScreen,
                                    id: ScreenNavigationSetup.id,
                                    arguments: searchScreenController
                                        .suggestionList[index]);
                              },
                              title: Text(
                                  searchScreenController.suggestionList[index]),
                              trailing: InkWell(
                                onTap: () {
                                  searchScreenController.suggestionInput(
                                      searchScreenController
                                          .suggestionList[index]);
                                },
                                child: Icon(
                                  Icons.north_west_rounded,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .color,
                                ),
                              ),
                            ),
                          )))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
