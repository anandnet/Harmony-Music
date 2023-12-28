import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final homeScreenController = Get.find<HomeScreenController>();
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: IntrinsicHeight(
          child: Obx(
            () => NavigationRail(
              useIndicator: false,
              selectedIndex:
                  homeScreenController.tabIndex.value, //_selectedIndex,
              onDestinationSelected: homeScreenController.onSideBarTabSelected,
              minWidth: 60,
              leading: SizedBox(height: size.height < 750 ? 30 : 60),
              labelType: NavigationRailLabelType.all,
              //backgroundColor: Colors.green,
              destinations: <NavigationRailDestination>[
                railDestination("home".tr),
                railDestination("songs".tr),
                railDestination("playlists".tr),
                railDestination("albums".tr),
                railDestination("artists".tr),
                //railDestination("Settings")
                const NavigationRailDestination(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  icon: Icon(Icons.settings_rounded),
                  label: SizedBox.shrink(),
                  selectedIcon: Icon(Icons.settings_rounded),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  NavigationRailDestination railDestination(String label) {
    return NavigationRailDestination(
      icon: const SizedBox.shrink(),
      label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: RotatedBox(quarterTurns: -1, child: Text(label))),
    );
  }
}
