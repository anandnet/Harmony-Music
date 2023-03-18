import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/quick_picks.dart';

import '../player/player_controller.dart';
import 'image_widget.dart';

class QuickPicksWidget extends StatelessWidget {
  const QuickPicksWidget({super.key, required this.content});
  final QuickPicks content;

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Discover",
                style: Theme.of(context).textTheme.titleLarge,
              )),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: content.songList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: .26 / 1,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 5,
                ),
                itemBuilder: (_, item) {
                  return InkWell(
                    onTap: () {
                      playerController.pushSongToQueue(content.songList[item]);
                    },
                    child: ListTile(
                      leading: SizedBox(
                          width: 50,
                          child: ImageWidget(song: content.songList[item])),
                      title: Text(
                        content.songList[item].title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        "${content.songList[item].artist[0]["name"]}",
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  );
                }),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}
