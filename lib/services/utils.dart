import 'dart:math';

import '../helper.dart';
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

Map<String, dynamic>? getFixedColumnItem(Map<String, dynamic> item, int index) {
  if (!item['fixedColumns'][index]['musicResponsiveListItemFixedColumnRenderer']
          ['text']
      .containsKey('runs')) {
    return null;
  }

  return item['fixedColumns'][index]
      ['musicResponsiveListItemFixedColumnRenderer'];
}

///Check if Steam Url or given epoch is expired
bool isExpired({String? url, int? epoch}) {
  if (url != null) {
    RegExpMatch? match = RegExp(".expire=([0-9]+)?&").firstMatch(url);
    if (match != null) {
      epoch = int.parse(match[1]!);
    }
  }

  if (epoch != null &&
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1800 < epoch!) {
    printINFO(
        "${DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1800}  $epoch");
    printINFO("Url or epoch is not Expired");
    return false;
  }
  printINFO("Url or epoch is Expired");
  return true;
}

void parseMenuPlaylists(
    Map<String, dynamic> data, Map<String, dynamic> result) {
  var watch_menu = findObjectsByKey(
      nav(data, ['menu', 'menuRenderer', 'items']),
      'menuNavigationItemRenderer');
  for (var item in watch_menu
      .map((item) => item['menuNavigationItemRenderer'])
      .toList()) {
    var watch_key;
    var icon = nav(item, ['icon', 'iconType']);
    if (icon == 'MUSIC_SHUFFLE') {
      watch_key = 'shuffleId';
    } else if (icon == 'MIX') {
      watch_key = 'radioId';
    } else {
      continue;
    }
    var watch_id = nav(
        item, ['navigationEndpoint', 'watchPlaylistEndpoint', 'playlistId']);
    watch_id ??=
        nav(item, ['navigationEndpoint', 'watchEndpoint', 'playlistId']);
    if (watch_id != null) {
      result[watch_key] = watch_id;
    }
  }
}

List<dynamic> findObjectsByKey(List<dynamic> objectList, String key,
    {String? nested}) {
  List<dynamic> objects = [];
  for (dynamic item in objectList) {
    if (nested != null) {
      item = item[nested];
    }
    if (item.containsKey(key)) {
      objects.add(item);
    }
  }
  return objects;
}

String? getSearchParams(String? filter, String? scope, bool ignoreSpelling) {
  String filteredParam1 = 'EgWKAQI';
  String? params;
  String? param1;
  String? param2;
  String? param3;

  if (filter == null && scope == null && !ignoreSpelling) {
    return params;
  }

  if (scope == 'uploads') {
    params = 'agIYAw%3D%3D';
  }

  if (scope == 'library') {
    if (filter != null) {
      param1 = filteredParam1;
      param2 = _getParam2(filter);
      param3 = 'AWoKEAUQCRADEAoYBA%3D%3D';
    } else {
      params = 'agIYBA%3D%3D';
    }
  }

  if (scope == null && filter != null) {
    if (filter == 'playlists') {
      params = 'Eg-KAQwIABAAGAAgACgB';
      if (!ignoreSpelling) {
        params += 'MABqChAEEAMQCRAFEAo%3D';
      } else {
        params += 'MABCAggBagoQBBADEAkQBRAK';
      }
    } else if (filter.contains('playlists')) {
      param1 = 'EgeKAQQoA';
      if (filter == 'featured_playlists') {
        param2 = 'Dg';
      } else {
        param2 = 'EA';
      }
      if (!ignoreSpelling) {
        param3 = 'BagwQDhAKEAMQBBAJEAU%3D';
      } else {
        param3 = 'BQgIIAWoMEA4QChADEAQQCRAF';
      }
    } else {
      param1 = filteredParam1;
      param2 = _getParam2(filter);
      if (!ignoreSpelling) {
        param3 = 'AWoMEA4QChADEAQQCRAF';
      } else {
        param3 = 'AUICCAFqDBAOEAoQAxAEEAkQBQ%3D%3D';
      }
    }
  }

  if (scope == null && filter == null && ignoreSpelling) {
    params = 'EhGKAQ4IARABGAEgASgAOAFAAUICCAE%3D';
  }

  return params ?? (param1! + param2! + param3!);
}

String? _getParam2(String filter) {
  final filterParams = {
    'songs': 'I',
    'videos': 'Q',
    'albums': 'Y',
    'artists': 'g',
    'playlists': 'o'
  };
  return filterParams[filter];
}
