import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';

import '../widgets/home_list_widget.dart';
import '../widgets/quickpickswidget.dart';
import 'home_screen_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlayerController playerController = Get.find<PlayerController>();
  final HomeScreenController homeScreenController =
      Get.find<HomeScreenController>();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: FloatingActionButton(
              focusElevation: 0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              elevation: 0,
              onPressed: () {},
              child: const Icon(Icons.search)),
        ),
      ),
      body: Row(
        children: <Widget>[
          // create a navigation rail
         Obx(() => NavigationRail(
            selectedIndex: homeScreenController.tabIndex.value, //_selectedIndex,
            onDestinationSelected: homeScreenController.onTabSelected,
            minWidth: 60,
            leading: const SizedBox(height: 100),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.green,
            destinations: <NavigationRailDestination>[
              railDestination("Home"),
              railDestination("Songs"),
              railDestination("Playlists"),
              railDestination("Albums"),
              railDestination("Artists"),
              railDestination("Settings")
            ],
            // selectedIconTheme: IconThemeData(color: Colors.white),
            unselectedIconTheme: const IconThemeData(color: Colors.black),
            selectedLabelTextStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white38),
          ),),
          const VerticalDivider(thickness: 1, width: 2),
          Expanded(
            child: Center(
              child: Obx(
                (){
                  if(homeScreenController.tabIndex.value==0){
                  return Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100, top: 100),
                      child: Obx(() {
                        return Column(
                          children: homeScreenController.isContentFetched.value
                              ? (homeScreenController.homeContentList)
                                  .map((element) {
                                  if (element.runtimeType.toString() ==
                                      "QuickPicks") {
                                    return QuickPicksWidget(content: element);
                                  } else {
                                    return PlaylistListWidget(
                                      content: element,
                                    );
                                  }
                                }).toList()
                              : [const SizedBox()],
                        );
                      }),
                    ),
                  );
                }
                else{
                  return Center(child: Text("${homeScreenController.tabIndex.value}"),);
                }
                }
              ),
            ),
          )
        ],
      ),
    );
  }

  NavigationRailDestination railDestination(String label) {
    return NavigationRailDestination(
      icon: const SizedBox.shrink(),
      label: RotatedBox(quarterTurns: -1, child: Text(label)),
    );
  }
}
