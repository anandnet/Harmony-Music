import 'dart:math';

import 'nav_parser.dart';

int getDatestamp() {
  final DateTime now = DateTime.now();
  final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration difference = now.difference(epoch);
  final int days = difference.inDays;
  return days;
}

int? parseDuration(String duration) {
  if (duration == null) {
    return null;
  }
  List<int> mappedIncrements = List.generate(3, (i) => max(0, 3600 - 60 * i));
  List<String> times = duration.split(":").reversed.toList();
  int seconds = 0;
  for (var i = 0; i < times.length; i++) {
    seconds += mappedIncrements[i] * int.parse(times[i]);
  }
  return seconds;
}

String validatePlaylistId(String playlistId) {
  return playlistId.startsWith('VL') ? playlistId.substring(2) : playlistId;
}

int sumTotalDuration(Map<String, dynamic> item) {
  if (!item.containsKey('tracks')) {
    return 0;
  }

  List tracks = item['tracks'];
  int totalDuration = 0;

  for (var track in tracks) {
    if (track.containsKey('duration_seconds')) {
      totalDuration += track['duration_seconds'] as int;
    }
  }

  return totalDuration;
}

String? getItemText(Map<String, dynamic> item, int index,
    {int runIndex = 0, bool noneIfAbsent = false}) {
  Map<String, dynamic>? column = getFlexColumnItem(item, index);
  if (column == null) {
    return noneIfAbsent ? null : "";
  }
  List<dynamic> runs = column['text']['runs'];
  if (noneIfAbsent && runs.length < runIndex + 1) {
    return null;
  }
  return runs[runIndex]['text'];
}

  Map<String, dynamic>? getFixedColumnItem(
      Map<String, dynamic> item, int index) {
    if (!item['fixedColumns'][index]
            ['musicResponsiveListItemFixedColumnRenderer']['text']
        .containsKey('runs')) {
      return null;
    }

    return item['fixedColumns'][index]
        ['musicResponsiveListItemFixedColumnRenderer'];
  }

  

