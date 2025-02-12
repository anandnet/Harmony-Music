import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';
import 'package:sidebar_with_animation/animated_side_bar.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobileOrTabScreen = size.width < 480;
    final homeScreenController = Get.find<HomeScreenController>();
    return Align(
      alignment: Alignment.topCenter,
      child: isMobileOrTabScreen
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: IntrinsicHeight(
                child: Obx(
                  () => NavigationRail(
                    useIndicator: !isMobileOrTabScreen,
                    selectedIndex:
                        homeScreenController.tabIndex.value, //_selectedIndex,
                    onDestinationSelected:
                        homeScreenController.onSideBarTabSelected,
                    minWidth: 60,
                    leading: SizedBox(height: size.height < 750 ? 30 : 60),
                    minExtendedWidth: 250,
                    extended: !isMobileOrTabScreen,
                    labelType: isMobileOrTabScreen
                        ? NavigationRailLabelType.all
                        : NavigationRailLabelType.none,
                    //backgroundColor: Colors.green,
                    destinations: <NavigationRailDestination>[
                      railDestination(
                          "home".tr, isMobileOrTabScreen, Icons.home),
                      railDestination(
                          "songs".tr, isMobileOrTabScreen, Icons.art_track),
                      railDestination("playlists".tr, isMobileOrTabScreen,
                          Icons.featured_play_list),
                      railDestination(
                          "albums".tr, isMobileOrTabScreen, Icons.album),
                      railDestination(
                          "artists".tr, isMobileOrTabScreen, Icons.people),
                      //railDestination("Settings")
                      const NavigationRailDestination(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        icon: Icon(Icons.settings),
                        label: SizedBox.shrink(),
                        selectedIcon: Icon(Icons.settings),
                      )
                    ],
                  ),
                ),
              ))
          : Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: SideBarAnimated(
                onTap: homeScreenController.onSideBarTabSelected,
                sideBarColor: Theme.of(context).primaryColor.withAlpha(250),
                animatedContainerColor: Theme.of(context).colorScheme.secondary,
                hoverColor:
                    Theme.of(context).colorScheme.secondary.withAlpha(180),
                splashColor: Theme.of(context).colorScheme.secondary,
                highlightColor:
                    Theme.of(context).colorScheme.secondary.withAlpha(180),
                widthSwitch: 800,
                mainLogoImage: 'assets/icons/icon.png',
                sidebarItems: [
                  SideBarItem(
                    iconSelected: Icons.home,
                    iconUnselected: Icons.home_outlined,
                    text: 'home'.tr,
                  ),
                  SideBarItem(
                    iconSelected: Icons.audiotrack,
                    iconUnselected: Icons.audiotrack,
                    text: 'songs'.tr,
                  ),
                  SideBarItem(
                    iconSelected: Icons.library_music,
                    iconUnselected: Icons.library_music_outlined,
                    text: 'playlists'.tr,
                  ),
                  SideBarItem(
                    iconSelected: Icons.album,
                    iconUnselected: Icons.album_outlined,
                    text: 'albums'.tr,
                  ),
                  SideBarItem(
                    iconSelected: Icons.person,
                    text: 'artists'.tr,
                  ),
                  SideBarItem(
                    iconSelected: Icons.settings,
                    iconUnselected: Icons.settings_outlined,
                    text: 'settings'.tr,
                  ),
                ],
              ),
            ),
    );
  }

  NavigationRailDestination railDestination(
      String label, bool isMobileOrTabScreen, IconData icon) {
    return isMobileOrTabScreen
        ? NavigationRailDestination(
            icon: const SizedBox.shrink(),
            label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: isMobileOrTabScreen
                    ? RotatedBox(quarterTurns: -1, child: Text(label))
                    : Text(label)),
          )
        : NavigationRailDestination(
            icon: Icon(icon),
            label: Text(label),
            padding: const EdgeInsets.only(left: 10),
            indicatorShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            indicatorColor: Colors.amber);
  }
}
