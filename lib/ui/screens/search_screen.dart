import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/screens/search_screen_controller.dart';

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
             child:Column(
               children: [
                 Padding(
                  padding: const EdgeInsets.only(left: 10,top: 80),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).textTheme.titleMedium!.color,
                    ),
                    onPressed: () {
                      Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
                    },
                  ),
            ),
               ],
             ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 90,left: 5),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Search",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: searchScreenController.textInputController,
                    onChanged: searchScreenController.onChanged,
                     autofocus: true,
                     cursorColor: Theme.of(context).textTheme.bodySmall!.color,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 5),
                      
                      focusColor: Colors.white,
                      hintText: 'Enter a search term',
                    ),
                  ),
                  Expanded(
                      child: Obx(() => ListView.builder(
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            itemCount: searchScreenController.suggestionList.length,
                            itemBuilder: (context, index) => ListTile(
                              onTap: () {
                                Get.toNamed(ScreenNavigationSetup.searchResultScreen,
                                    id: ScreenNavigationSetup.id,
                                    arguments:
                                        searchScreenController.suggestionList[index]);
                              },
                              title:
                                  Text(searchScreenController.suggestionList[index]),
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
