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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 100),
            child: TextField(
              controller: searchScreenController.textInputController,
              onChanged: searchScreenController.onChanged,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a search term',
              ),
            ),
          ),
          Expanded(
              child: Obx(() => ListView.builder(
                    physics: const ClampingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemCount: searchScreenController.suggestionList.length,
                    itemBuilder: (context, index) => ListTile(
                      onTap: () {
                        Get.toNamed(ScreenNavigationSetup.searchResultScreen,
                            id: ScreenNavigationSetup.id,
                            arguments:
                                searchScreenController.suggestionList[index]);
                      },
                      title: Text(searchScreenController.suggestionList[index]),
                    ),
                  )))
        ],
      ),
    );
  }
}
