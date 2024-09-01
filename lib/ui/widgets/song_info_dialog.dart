import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '/ui/widgets/common_dialog_widget.dart';

class SongInfoDialog extends StatelessWidget {
  final MediaItem song;
  final bool isDownloaded;
  const SongInfoDialog(
      {super.key, required this.song, required this.isDownloaded});

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic>? streamInfo;
    final nullVal = {
      "audioCodec": null,
      "bitrate": null,
      "loudnessDb": null,
      "approxDurationMs": null
    };
    if (isDownloaded) {
      streamInfo =
          Hive.box("SongDownloads").get(song.id)["streamInfo"] ?? nullVal;
    } else {
      final dbStreamData = Hive.box("SongsUrlCache").get(song.id);
      streamInfo = dbStreamData != null
          ? dbStreamData[Hive.box('AppPrefs').get('streamingQuality') + 1]
          : nullVal;
    }
    return CommonDialog(
      child: SizedBox(
        height: Get.mediaQuery.size.height * .7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text("songInfo".tr,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(),
            Expanded(
                child: ListView(
              children: [
                InfoItem(title: "id".tr, value: song.id),
                InfoItem(title: "title".tr, value: song.title),
                InfoItem(title: "albums".tr, value: song.album ?? "NA"),
                InfoItem(title: "artists".tr, value: song.artist ?? "NA"),
                InfoItem(
                    title: "duration".tr,
                    value:
                        "${streamInfo!["approxDurationMs"] ?? song.duration?.inMilliseconds ?? "NA"} ms"),
                InfoItem(
                    title: "audioCodec".tr,
                    value: streamInfo["audioCodec"] ?? "NA"),
                InfoItem(
                    title: "bitrate".tr,
                    value: "${streamInfo["bitrate"] ?? "NA"}"),
                InfoItem(
                    title: "loudnessDb".tr,
                    value: "${streamInfo["loudnessDb"] ?? "NA"}"),
              ],
            )),
            const Divider(),
            SizedBox(
              height: 50,
              child: Align(
                alignment: Alignment.center,
                child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 25),
                      child: Text("close".tr),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final String title;
  final String value;
  const InfoItem({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
          ),
          TextSelectionTheme(
            data: TextSelectionThemeData(
              cursorColor: Theme.of(context).colorScheme.secondary,
              selectionColor: Theme.of(context).colorScheme.secondary,
              selectionHandleColor: Theme.of(context).colorScheme.secondary,
            ),
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )
        ],
      ),
    );
  }
}
