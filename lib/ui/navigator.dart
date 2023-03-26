import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/home_screen.dart';
import 'package:harmonymusic/ui/screens/playlist_screen.dart';
import 'package:harmonymusic/ui/screens/search_screen.dart';

class ScreenNavigationSetup {
  ScreenNavigationSetup._();

  static const id = 1;
  static const homeScreen = '/homeScreen';
  static const playlistScreen = '/playlistScreen';
  static const searchScreen = '/searchScreen';
}

class ScreenNavigation extends StatelessWidget {
  const ScreenNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: Get.nestedKey(ScreenNavigationSetup.id),
        initialRoute: '/homeScreen',
        onGenerateRoute: (settings) {
          Get.routing.args = settings.arguments;
          if (settings.name == ScreenNavigationSetup.homeScreen) {
            return GetPageRoute(page: () => const HomeScreen());
          } else if (settings.name == ScreenNavigationSetup.playlistScreen) {
            return GetPageRoute(page: () => const PlayListScreen());
          } else if (settings.name == ScreenNavigationSetup.searchScreen) {
            return GetPageRoute(page: () => const SearchScreen());
          }
        });
  }
}
