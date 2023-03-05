import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/playlist.dart';

class PlayListScreen extends StatelessWidget {
  ///PlaylistScreen renders playlist content
  ///
  ///Playlist title,image,songs
  const PlayListScreen({super.key, required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0, //_selectedIndex,
            minWidth: 60,
            leading: const SizedBox(height: 70),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.green,
            destinations: <NavigationRailDestination>[
              railDestination("Songs"),
              railDestination(""),
            ],
            // selectedIconTheme: IconThemeData(color: Colors.white),
            unselectedIconTheme: const IconThemeData(color: Colors.black),
            selectedLabelTextStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white38),
          ),
          const VerticalDivider(thickness: 1, width: 2),
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(top: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.title,
                  style: const TextStyle(
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: CachedNetworkImage(
                    cacheKey: "${playlist.playlistId}_plalist",
                    alignment: Alignment.centerLeft,
                      imageUrl: playlist.thumbnailUrl),
                ),
                Text(playlist.description ?? ""),
                const Divider(),
                const Text("Songs"),
                Expanded(
                    child:
                        ListView.builder(
                          itemCount: 25,
                          itemBuilder: (_, index) => ListTile(
                          title: Text("$index"),
                        )))
              ],
            ),
          ))
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
