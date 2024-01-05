import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';

import '/ui/navigator.dart';
import 'search_screen_controller.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchScreenController = Get.put(SearchScreenController());
    final settingsScreenController = Get.find<SettingsScreenController>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(
        () => Row(
          children: [
            settingsScreenController.isBottomNavBarEnabled.isFalse
                ? Container(
                    width: 60,
                    color:
                        Theme.of(context).navigationRailTheme.backgroundColor,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .color,
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
                  )
                : const SizedBox(
                    width: 15,
                  ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 90, left: 5),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "search".tr,
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
                        searchScreenController.addToHistryQueryList(val);
                      },
                      autofocus: settingsScreenController.isBottomNavBarEnabled.isFalse,
                      cursorColor: Theme.of(context).textTheme.bodySmall!.color,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 5),
                          focusColor: Colors.white,
                          hintText: "searchDes".tr,
                          suffix: IconButton(
                            onPressed: searchScreenController.reset,
                            icon: const Icon(Icons.close),
                            splashRadius: 16,
                            iconSize: 19,
                          )),
                    ),
                    Expanded(
                      child: Obx(() {
                        final isEmpty = searchScreenController
                                .suggestionList.isEmpty ||
                            searchScreenController.textInputController.text ==
                                "";
                        final list = isEmpty
                            ? searchScreenController.historyQuerylist.toList()
                            : searchScreenController.suggestionList.toList();
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 5),
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          itemCount: list.length,
                          itemBuilder: (context, index) => ListTile(
                            contentPadding:
                                const EdgeInsets.only(left: 10, right: 20),
                            onTap: () {
                              Get.toNamed(
                                  ScreenNavigationSetup.searchResultScreen,
                                  id: ScreenNavigationSetup.id,
                                  arguments: list[index]);
                              searchScreenController
                                  .addToHistryQueryList(list[index]);
                            },
                            leading: isEmpty ? const Icon(Icons.history) : null,
                            minLeadingWidth: 20,
                            dense: true,
                            title: Text(list[index]),
                            trailing: SizedBox(
                              width: 80,
                              child: Row(
                                children: [
                                  isEmpty
                                      ? IconButton(
                                          iconSize: 18,
                                          splashRadius: 18,
                                          visualDensity: const VisualDensity(
                                              horizontal: -2),
                                          onPressed: () {
                                            searchScreenController
                                                .removeQueryFromHistory(
                                                    list[index]);
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .color,
                                          ),
                                        )
                                      : const SizedBox(
                                          width: 40,
                                        ),
                                  IconButton(
                                    iconSize: 20,
                                    splashRadius: 18,
                                    visualDensity:
                                        const VisualDensity(horizontal: -2),
                                    onPressed: () {
                                      searchScreenController
                                          .suggestionInput(list[index]);
                                    },
                                    icon: Icon(
                                      Icons.north_west,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
