import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/loader.dart';
import '/services/music_service.dart';
import '/ui/player/player_controller.dart';
import '../navigator.dart';
import '../widgets/snackbar.dart';

class AppLinksController extends GetxController {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void onInit() {
    initDeepLinks();
    super.onInit();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      await filterLinks(appLink);
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      await filterLinks(uri);
    });
  }

  Future<void> filterLinks(Uri uri) async {
    final playerController = Get.find<PlayerController>();
    if (playerController.playerPanelController.isPanelOpen) {
      playerController.playerPanelController.close();
    }

    if (uri.host == "youtube.com" ||
        uri.host == "music.youtube.com" ||
        uri.host == "youtu.be") {
      //printINFO("pathsegmet: ${uri.pathSegments} params:${uri.queryParameters}");
      if (uri.pathSegments[0] == "playlist" &&
          (!uri.queryParameters.containsKey("playnext") || uri.host == "music.youtube.com")) {
        final browseId = uri.queryParameters['list'];
        await openPlaylistOrAlbum(browseId!);
      } else if (uri.pathSegments[0] == "shorts") {
        ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
            Get.context!, "Not a Song/Music-Video !",
            size: SanckBarSize.MEDIUM));
      } else if (uri.pathSegments[0] == "watch") {
        final songId = uri.queryParameters['v'];
        await playSong(songId!);
      } else if (uri.pathSegments[0] == "channel") {
        final browseId = uri.pathSegments[1];
        await openArtist(browseId);
      } else if ((uri.queryParameters.isEmpty || uri.query.contains("si="))  && uri.host == "youtu.be") {
        final songId = uri.pathSegments[0];
        await playSong(songId);
      }
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
          Get.context!, "Not a valid link!",
          size: SanckBarSize.MEDIUM));
    }
  }

  Future<void> openPlaylistOrAlbum(String browseId) async {
    if (browseId.contains("OLAK5uy")) {
      Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
          id: ScreenNavigationSetup.id, arguments: [true, browseId, true]);
    } else {
      Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
          id: ScreenNavigationSetup.id, arguments: [false, browseId, true]);
    }
  }

  Future<void> openArtist(String channelId) async {
    await Get.toNamed(ScreenNavigationSetup.artistScreen,
        id: ScreenNavigationSetup.id, arguments: [true, channelId]);
  }

  Future<void> playSong(String songId) async {
    showDialog(
        context: Get.context!,
        builder: (context) => const Center(
                child: LoadingIndicator(
              strokeWidth: 5,
            )),
        barrierDismissible: false);
    final result = await Get.find<MusicServices>().getSongWithId(songId);
    Navigator.of(Get.context!).pop();
    if (result[0]) {
      Get.find<PlayerController>().playPlayListSong(List.from(result[1]), 0);
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
          Get.context!, "Not a Song/Music-Video !",
          size: SanckBarSize.MEDIUM));
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}
