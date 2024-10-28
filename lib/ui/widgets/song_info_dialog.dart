import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '/ui/widgets/common_dialog_widget.dart';

class SongInfoDialog extends StatelessWidget {
  final MediaItem song;
  final bool isDownloaded;

  const SongInfoDialog({
    required this.song,
    required this.isDownloaded,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var streamInfo = _getStreamInfo(song.id);
    return CommonDialog(
      child: SizedBox(
        height: Get.mediaQuery.size.height * .7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('songInfo'.tr, style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(),
            Expanded(
                child: ListView(
              children: [
                InfoItem(title: 'id'.tr, value: song.id),
                InfoItem(title: 'title'.tr, value: song.title),
                InfoItem(title: 'albums'.tr, value: song.album ?? 'NA'),
                InfoItem(title: 'artists'.tr, value: song.artist ?? 'NA'),
                InfoItem(
                    title: 'duration'.tr,
                    value: "${streamInfo["approxDurationMs"] ?? song.duration?.inMilliseconds ?? "NA"} ms"),
                InfoItem(title: 'audioCodec'.tr, value: streamInfo['audioCodec'] ?? 'NA'),
                InfoItem(title: 'bitrate'.tr, value: "${streamInfo["bitrate"] ?? "NA"}"),
                InfoItem(title: 'loudnessDb'.tr, value: "${streamInfo["loudnessDb"] ?? "NA"}"),
              ],
            )),
            const Divider(),
            SizedBox(
              height: 50,
              child: Align(
                child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      child: Text('close'.tr),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  Map<dynamic, dynamic> _getStreamInfo(String id) {
    Map<dynamic, dynamic> tempstreamInfo;
    final nullVal = {'audioCodec': null, 'bitrate': null, 'loudnessDb': null, 'approxDurationMs': null};
    if (isDownloaded) {
      final song = Hive.box('SongDownloads').get(id);

      tempstreamInfo = song['streamInfo'] == null ? nullVal : song['streamInfo'][1];
    } else {
      final dbStreamData = Hive.box('SongsUrlCache').get(id);
      tempstreamInfo = dbStreamData != null ? dbStreamData[Hive.box('AppPrefs').get('streamingQuality') + 1] : nullVal;
    }
    return tempstreamInfo;
  }
}

class InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const InfoItem({required this.title, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
          ),
          TextSelectionTheme(
            data: Theme.of(context).textSelectionTheme,
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
