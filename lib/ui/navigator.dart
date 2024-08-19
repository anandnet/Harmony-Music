import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/models/artist.dart';
import 'package:harmonymusic/models/playlist.dart';

import 'package:harmonymusic/ui/screens/Artists/artist_screen.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen.dart';
import 'package:harmonymusic/ui/screens/PlaylistNAlbum/playlistnalbum_screen.dart';

import 'screens/Search/search_result_screen.dart';
import 'screens/Search/search_screen.dart';

class ScreenNavigationSetup {
  ScreenNavigationSetup._();

  static const id = 1;
  static const homeScreen = '/homeScreen';
  static const playlistNAlbumScreen = '/playlistNAlbumScreen';
  static const searchScreen = '/searchScreen';
  static const searchResultScreen = '/searchResultScreen';
  static const artistScreen = '/artistScreen';
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
            return GetPageRoute(
                page: () => const HomeScreen(), settings: settings);
          } else if (settings.name ==
              ScreenNavigationSetup.playlistNAlbumScreen) {
            final args = settings.arguments as List;
            final id = args[2]
                ? args[1]
                : args[0]
                    ? (args[1] as Album).browseId
                    : (args[1] as Playlist).playlistId;
            return GetPageRoute(
                page: () => PlaylistNAlbumScreen(key: Key(id)),
                settings: settings);
          } else if (settings.name == ScreenNavigationSetup.searchScreen) {
            return GetPageRoute(
                page: () => const SearchScreen(), settings: settings);
          } else if (settings.name ==
              ScreenNavigationSetup.searchResultScreen) {
            return GetPageRoute(
                page: () => const SearchResultScreen(), settings: settings);
          } else if (settings.name == ScreenNavigationSetup.artistScreen) {
            final args = settings.arguments as List;
            final id = args[0] ? args[1] : (args[1] as Artist).browseId;
            return GetPageRoute(
                page: () => ArtistScreen(
                      key: Key(id),
                    ),
                settings: settings);
          }
          return null;
        });
  }
}
