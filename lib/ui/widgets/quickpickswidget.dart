import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/quick_picks.dart';

import '../player/player_controller.dart';

class QuickPicksWidget extends StatelessWidget {
  const QuickPicksWidget({
    super.key,required this.content
  });
  final QuickPicks content;

  @override
  Widget build(BuildContext context) {
     final PlayerController playerController = Get.find<PlayerController>();
    return Container(
      height: 320,
      width: double.infinity,
      child: Column(
        children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Quick Pics",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              )),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 20,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: .26 / 1,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 5,
                ),
                itemBuilder: (_, item) {
                  return InkWell(
                    onTap: (){playerController.pushSongToPlaylist(content.songList[item]);},
                    child: ListTile(
                      leading: SizedBox(
                      width: 50,
                      child: CachedNetworkImage(
                          imageUrl: content.songList[item].thumbnail
                              .sizewith(50))),
                      title: Text(
                    content.songList[item].title,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                      "${content.songList[item].artist[0]["name"]}",maxLines: 1,),
                    ),
                  );
                }),
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}
