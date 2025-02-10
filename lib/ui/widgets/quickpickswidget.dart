import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/models/quick_picks.dart';
import '../player/player_controller.dart';
import 'image_widget.dart';
import 'songinfo_bottom_sheet.dart';

class QuickPicksWidget extends StatelessWidget {
  const QuickPicksWidget(
      {super.key, required this.content, this.scrollController});
  final QuickPicks content;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    return SizedBox(
      height: 340,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content.title.toLowerCase().removeAllWhitespace.tr,
                style: Theme.of(context).textTheme.titleLarge,
              )),
          const SizedBox(height: 10),
          Expanded(
            child: Scrollbar(
              thickness: GetPlatform.isDesktop ? null : 0,
              controller: scrollController,
              child: GridView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: content.songList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: .26 / 1,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (_, item) {
                    return Listener(
                      onPointerDown: (PointerDownEvent event) {
                        if (event.buttons == kSecondaryMouseButton) {
                          //show songinfobotomsheet
                          showModalBottomSheet(
                            constraints: const BoxConstraints(maxWidth: 500),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10.0)),
                            ),
                            isScrollControlled: true,
                            context: playerController
                                .homeScaffoldkey.currentState!.context,
                            barrierColor: Colors.transparent.withAlpha(100),
                            builder: (context) => SongInfoBottomSheet(
                              content.songList[item],
                            ),
                          ).whenComplete(
                              () => Get.delete<SongInfoController>());
                        }
                      },
                      child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 5),
                          leading: ImageWidget(
                            song: content.songList[item],
                            size: 55,
                          ),
                          title: Text(
                            content.songList[item].title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            "${content.songList[item].artist}",
                            maxLines: 1,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          onTap: () {
                            playerController
                                .pushSongToQueue(content.songList[item]);
                          },
                          onLongPress: () {
                            showModalBottomSheet(
                              constraints: const BoxConstraints(maxWidth: 500),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10.0)),
                              ),
                              isScrollControlled: true,
                              context: playerController
                                  .homeScaffoldkey.currentState!.context,
                              //constraints: BoxConstraints(maxHeight:Get.height),
                              barrierColor: Colors.transparent.withAlpha(100),
                              builder: (context) =>
                                  SongInfoBottomSheet(content.songList[item]),
                            ).whenComplete(
                                () => Get.delete<SongInfoController>());
                          },
                          trailing: (GetPlatform.isDesktop)
                              ? IconButton(
                                  splashRadius: 20,
                                  onPressed: () {
                                    showModalBottomSheet(
                                      constraints:
                                          const BoxConstraints(maxWidth: 500),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(10.0)),
                                      ),
                                      isScrollControlled: true,
                                      context: playerController.homeScaffoldkey
                                          .currentState!.context,
                                      //constraints: BoxConstraints(maxHeight:Get.height),
                                      barrierColor:
                                          Colors.transparent.withAlpha(100),
                                      builder: (context) => SongInfoBottomSheet(
                                          content.songList[item]),
                                    ).whenComplete(
                                        () => Get.delete<SongInfoController>());
                                  },
                                  icon: const Icon(Icons.more_vert))
                              : null),
                    );
                  }),
            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}
