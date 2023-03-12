//navigations
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:harmonymusic/services/utils.dart';

const single_column = ['contents', 'singleColumnBrowseResultsRenderer'];
const tab_content = ['tabs', 0, 'tabRenderer', 'content'];
const List<dynamic> single_column_tab = [
  'contents',
  'singleColumnBrowseResultsRenderer',
  'tabs',
  0,
  'tabRenderer',
  'content'
];
const section_list = ['sectionListRenderer', 'contents'];
const description_shelf = ['musicDescriptionShelfRenderer'];
const run_text = ['runs', 0, 'text'];
const description = ['description', 'runs', 0, 'text'];
const carousel_title = [
  'header',
  'musicCarouselShelfBasicHeaderRenderer',
  'title',
  'runs',
  0
];
const mtrir = 'musicTwoRowItemRenderer';
const mrlir = 'musicResponsiveListItemRenderer';
const n_title = ['title', 'runs', 0]; //titile
const navigation_browse = ['navigationEndpoint', 'browseEndpoint'];
const page_type = [
  'browseEndpointContextSupportedConfigs',
  'browseEndpointContextMusicConfig',
  'pageType'
];
const navigation_watch_playlist_id = [
  'navigationEndpoint',
  'watchPlaylistEndpoint',
  'playlistId'
];
const title_text = ['title', 'runs', 0, 'text'];
const thumbnail_renderer = [
  'thumbnailRenderer',
  'musicThumbnailRenderer',
  'thumbnail',
  'thumbnails'
];
const navigation_playlist_id = [
  'navigationEndpoint',
  'watchEndpoint',
  'playlistId'
];
const navigation_video_id = ['navigationEndpoint', 'watchEndpoint', 'videoId'];
const subtitle2 = ['subtitle', 'runs', 2, 'text'];
const navigation_browse_id = [
  'navigationEndpoint',
  'browseEndpoint',
  'browseId'
];

const text_run_navigation_browse_id = [];

const subtitle_badge_label = [
  'subtitleBadges',
  0,
  'musicInlineBadgeRenderer',
  'accessibilityData',
  'accessibilityData',
  'label'
];
const text_run_text = ['text', 'runs', 0, 'text'];
const text_run = ['text', 'runs', 0];
const badge_label = [
  'badges',
  0,
  'musicInlineBadgeRenderer',
  'accessibilityData',
  'accessibilityData',
  'label'
];
const thumbnail = ['thumbnail', 'thumbnails'];
const thumbnails = [
  'thumbnail',
  'musicThumbnailRenderer',
  'thumbnail',
  'thumbnails'
];

const navigation_video_type = [
  'watchEndpoint',
  'watchEndpointMusicSupportedConfigs',
  'watchEndpointMusicConfig',
  'musicVideoType'
];
const toggle_menu = 'toggleMenuServiceItemRenderer';
const List<dynamic> menu_items = ['menu', 'menuRenderer', 'items'];
const menu_service = ['menuServiceItemRenderer', 'serviceEndpoint'];
const play_button = [
  'overlay',
  'musicItemThumbnailOverlayRenderer',
  'content',
  'musicPlayButtonRenderer'
];
const menu_like_status = [
  'menu',
  'menuRenderer',
  'topLevelButtons',
  0,
  'likeButtonRenderer',
  'likeStatus'
];
const List<dynamic> section_list_item = ['sectionListRenderer', 'contents', 0];
const List<dynamic> thumnail_cropped = [
  'thumbnail',
  'croppedSquareThumbnailRenderer',
  'thumbnail',
  'thumbnails'
];
const subtitle3 = ['subtitle', 'runs', 4, 'text'];
const feedback_token = ['feedbackEndpoint', 'feedbackToken'];

List<Map<String, dynamic>> parseMixedContent(List<dynamic> rows) {
  List<Map<String, dynamic>> items = [];
  //inspect(rows);
  for (var row in rows) {
    if (description_shelf[0] == row.keys.first.toString()) {
      var results = nav(row, description_shelf);
      var title = nav(results, ['header', 'runs', 0, 'text']);
      var contents = nav(results, description);
    } else {
      var results = row.values.first;
      if (!results.containsKey('contents')) {
        continue;
      }
      var title = nav(results, carousel_title + ['text']);
      var contents = [];
      for (var result in results['contents']) {
        var data =
            nav(result, [mtrir], noneIfAbsent: true, funName: "parsedMixed1");
        dynamic content;
        if (data != null) {
          var pageType = nav(data, n_title + navigation_browse + page_type,
              noneIfAbsent: true, funName: "mixed1");
          if (pageType == null) {
            if (nav(data, navigation_watch_playlist_id) != null) {
              content = parseWatchPlaylistHome(data);
            } else {
              content = parseSong(data);
            }
          } else if (pageType == "MUSIC_PAGE_TYPE_ALBUM") {
            content = parseAlbum(data);
          } else if (pageType == "MUSIC_PAGE_TYPE_ARTIST") {
            content = parseRelatedArtist(data);
          } else if (pageType == "MUSIC_PAGE_TYPE_PLAYLIST") {
            content = parsePlaylist(data);
          }
        } else {
          data = nav(result, [mrlir]);
          content = parseSongFlat(data);
        }

        contents.add(content);
      }

      items.add({'title': title, 'contents': contents});
    }
  }
  return items;
}

Map<String, dynamic> parseSong(Map<dynamic, dynamic> result) {
  //inspect(result);
  var song = {
    'title': nav(result, title_text),
    'videoId': nav(result, navigation_video_id),
    'playlistId': nav(result, navigation_playlist_id,
        noneIfAbsent: true, funName: "parseSong"),
    'thumbnails': nav(result, thumbnail_renderer),
  };

  song.addAll(parseSongRuns(result['subtitle']['runs']));
  return song;
}

Map<String, dynamic> parseSongRuns(List<dynamic> runs) {
  Map<String, dynamic> parsed = {'artists': []};
  for (int i = 0; i < runs.length; i++) {
    Map<String, dynamic> run = runs[i];
    if (i % 2 != 0) {
      // uneven items are always separators
      continue;
    }
    String text = run['text'];
    if (run.containsKey('navigationEndpoint')) {
      // artist or album
      Map<String, dynamic> item = {
        'name': text,
        'id': nav(run, navigation_browse_id,
            noneIfAbsent: true, funName: "parseSongRuns")
      };

      if (item['id'] != null &&
          (item['id'].startsWith('MPRE') ||
              item['id'].contains("release_detail"))) {
        // album
        parsed['album'] = item;
      } else {
        // artist
        parsed['artists'].add(item);
      }
    } else {
      // note: YT uses non-breaking space \xa0 to separate number and magnitude
      RegExp regExp = RegExp(r"^\d([^ ])* [^ ]*$");
      if (regExp.hasMatch(text) && i > 0) {
        parsed['views'] = text.split(' ')[0];
      } else if (RegExp(r"^(\d+:)*\d+:\d+$").hasMatch(text)) {
        parsed['duration'] = text;
        parsed['duration_seconds'] = parseDuration(text);
      } else if (RegExp(r"^\d{4}$").hasMatch(text)) {
        parsed['year'] = text;
      } else {
        // artist without id
        parsed['artists'].add({'name': text, 'id': null});
      }
    }
  }
  return parsed;
}

Map<String, dynamic> parseAlbum(Map<dynamic, dynamic> result) {
  return {
    'title': nav(result, title_text),
    'artist': nav(result, subtitle2, noneIfAbsent: true, funName: "sub"),
    'browseId': nav(result, n_title + navigation_browse_id),
    'thumbnails': nav(result, thumbnail_renderer),
    //'isExplicit': nav(result, subtitle_badge_label, noneIfAbsent: true) != null,
  };
}

Map<String, dynamic> parseRelatedArtist(Map<String, dynamic> data) {
  return {
    'title': nav(data, title_text),
    'browseId': nav(data, n_title + navigation_browse_id),
    'thumbnails': nav(data, thumbnail_renderer),
  };
}

Map<String, dynamic> parsePlaylist(Map<String, dynamic> data) {
  //inspect(data);
  Map<String, dynamic> playlist = {
    'title': nav(data, title_text),
    'playlistId': nav(data, ['title', 'runs', 0] + navigation_browse_id),
    'thumbnails': nav(data, thumbnail_renderer)
  };

  var subtitle = data['subtitle'];
  if (subtitle.containsKey('runs')) {
    var runs = subtitle['runs'];
    playlist['description'] = runs.map((run) => run['text']).join('');
    if (runs.length == 3 && RegExp(r'\d+ ').hasMatch(nav(data, subtitle2))) {
      playlist['count'] = nav(data, subtitle2).split(' ')[0];
      playlist['author'] = parseSongArtistsRuns(runs.sublist(0, 1));
    }
  }

  return playlist;
}

List<dynamic> parseSongArtistsRuns(List<dynamic> runs) {
  //print(runs);
  List<Map<String, dynamic>> artists = [];
  int n = (runs.length / 2).floor() + 1;
  for (var j = 0; j < n; j++) {
    artists.add({
      'name': runs[j * 2]['text'],
      'id': nav(runs[j * 2], navigation_browse_id,
          noneIfAbsent: false, funName: "parseSongArtistsRuns"),
    });
  }
  return artists;
}

Map<String, dynamic> parseSongFlat(Map<String, dynamic> data) {
  //print(data);
  List<Map<String, dynamic>> columns = [];
  for (int i = 0; i < data['flexColumns'].length; i++) {
    columns.add(getFlexColumnItem(data, i));
  }

  Map<String, dynamic> song = {
    'title': nav(columns[0], text_run_text),
    'videoId': nav(columns[0], text_run + navigation_video_id,
        noneIfAbsent: true, funName: "parseSongFlat"),
    'artists': parseSongArtists(data, 1),
    'thumbnails': nav(data, thumbnails),
    //'isExplicit': nav(data, badge_label, noneIfAbsent: true) != null
  };
//checkpoint .contains
  if (columns.length > 2 && columns[2].isNotEmpty) {
    if (nav(columns[2], text_run).containsKey('navigationEndpoint')) {
      song['album'] = {
        'name': nav(columns[2], text_run_text),
        'id': nav(columns[2], text_run + navigation_browse_id)
      };
    }
  }

  return song;
}

List<dynamic>? parseSongArtists(Map<String, dynamic> data, int index) {
  var flexItem = getFlexColumnItem(data, index);
  if (flexItem == null) {
    return null;
  } else {
    var runs = flexItem['text']['runs'];
    return parseSongArtistsRuns(runs);
  }
}

Map<String, dynamic> getFlexColumnItem(Map<String, dynamic> item, int index) {
  if ((item['flexColumns']).length <= index ||
      !item['flexColumns'][index]['musicResponsiveListItemFlexColumnRenderer']
          .containsKey('text') ||
      !item['flexColumns'][index]['musicResponsiveListItemFlexColumnRenderer']
              ['text']
          .containsKey('runs')) {
    return {};
  }

  return item['flexColumns'][index]
      ['musicResponsiveListItemFlexColumnRenderer'];
}

Map<String, dynamic> parseWatchPlaylistHome(Map<dynamic, dynamic> data) {
  return {
    'title': nav(data, title_text),
    'playlistId': nav(data, navigation_watch_playlist_id),
    'thumbnails': nav(data, thumbnail_renderer),
  };
}

//For Song Watch Playlist

List<dynamic> parseWatchPlaylist(List<dynamic> results) {
  final tracks = <Map<String, dynamic>>[];
  const PPVWR = 'playlistPanelVideoWrapperRenderer';
  const PPVR = 'playlistPanelVideoRenderer';
  for (var result in results) {
    Map<String, dynamic>? counterpart;
    if (result.containsKey(PPVWR)) {
      counterpart =
          result[PPVWR]['counterpart'][0]['counterpartRenderer'][PPVR];
      result = result[PPVWR]['primaryRenderer'];
    }
    if (!result.containsKey(PPVR)) {
      continue;
    }
    final data = result[PPVR];
    if (data.containsKey('unplayableText')) {
      continue;
    }
    final track = parseWatchTrack(data);
    if (counterpart != null) {
      track['counterpart'] = parseWatchTrack(counterpart);
    }
    tracks.add(track);
  }
  return tracks;
}

Map<String, dynamic> parseWatchTrack(Map<String, dynamic> data) {
  final songInfo = parseSongRuns(data['longBylineText']['runs']);

  final track = {
    'videoId': data['videoId'],
    'title': nav(data, title_text),
    'length': nav(data, ['lengthText', 'runs', 0, 'text']),
    'thumbnails': nav(data, thumbnail),
    'videoType': nav(data, ['navigationEndpoint'] + navigation_video_type),
  };
  track.addAll(songInfo);
  return track;
}

String? getTabBrowseId(Map<String, dynamic> watchNextRenderer, int tabId) {
  if (!watchNextRenderer['tabs'][tabId]['tabRenderer']
      .containsKey('unselectable')) {
    return watchNextRenderer['tabs'][tabId]['tabRenderer']['endpoint']
        ['browseEndpoint']['browseId'];
  } else {
    return null;
  }
}

//playlist songs

List<dynamic> parsePlaylistItems(List<dynamic> results,
    {List<List<dynamic>>? menuEntries}) {
  List<dynamic> songs = [];

  int count = 1;
  for (dynamic result in results) {
    count += 1;
    if (!result.containsKey('musicResponsiveListItemRenderer')) {
      continue;
    }
    dynamic data = result['musicResponsiveListItemRenderer'];
    try {
      dynamic videoId, setVideoId;

      // if the item has a menu, find its setVideoId
      if (data.containsKey('menu')) {
        for (dynamic item in nav(data, menu_items)) {
          if (item.containsKey('menuServiceItemRenderer')) {
            dynamic menuService = nav(item, menu_service);
            //inspect(menuService);

            if (menuService.containsKey('playlistEditEndpoint')) {
              videoId = menuService['playlistEditEndpoint']['actions'][0]
                  ['removedVideoId'];
              // print("$videoId");
            }
          }
        }
      }

      // if item is not playable, the videoId was retrieved above
      if (nav(data, play_button) != null) {
        if (nav(data, play_button).containsKey('playNavigationEndpoint')) {
          videoId = nav(data, play_button)['playNavigationEndpoint']
              ['watchEndpoint']['videoId'];
        }
      }

      String? title = getItemText(data, 0);
      if (title == 'Song deleted') {
        continue;
      }

      List? artists = parseSongArtists(data, 1);

      dynamic album = parseSongAlbum({...data}, 2);

      dynamic duration;
      if (data.containsKey('fixedColumns')) {
        if (getFixedColumnItem(data, 0)!['text'].containsKey('simpleText')) {
          duration = getFixedColumnItem(data, 0)!['text']['simpleText'];
        } else {
          duration = getFixedColumnItem(data, 0)!['text']['runs'][0]['text'];
        }
      }

      dynamic thumbnails_;
      if (data.containsKey('thumbnail')) {
        thumbnails_ = nav(data, thumbnails);
      }

      bool isAvailable = true;
      if (data.containsKey('musicItemRendererDisplayPolicy')) {
        isAvailable = data['musicItemRendererDisplayPolicy'] !=
            'MUSIC_ITEM_RENDERER_DISPLAY_POLICY_GREY_OUT';
      }

      //print('here');
      dynamic song = {
        'videoId': videoId,
        'title': title,
        'artists': artists,
        'thumbnails': thumbnails_,
        'isAvailable': isAvailable,
      };

      if (duration != null) {
        song['length'] = duration;
        song['duration_seconds'] = parseDuration(duration);
      }

      if (menuEntries != null) {
        for (final List<dynamic> menuEntry in menuEntries) {
          song[menuEntry.last] = nav(
              data,
              menu_items +
                  menuEntry.map((e) => e).whereType<String>().toList());
        }
      }
      songs.add(song);
    } catch (e) {
      //print(e);
    }
  }
  return songs;
}

Map<String, dynamic>? parseSongAlbum(Map<String, dynamic> data, int index) {
  Map<String, dynamic> flexItem = getFlexColumnItem(data, index);
  // print("here");
  if (flexItem.isNotEmpty) {
    return {
      'name': getItemText(data, index),
      'id': getBrowseId(flexItem, 0),
    };
  }
  return null;
}

String? getBrowseId(Map<String, dynamic> item, int index) {
  if (item['text']['runs'][index].containsKey('navigationEndpoint')) {
    return nav(item['text']['runs'][index], navigation_browse_id);
  }
  return null;
}

Map<String, dynamic> parseSongMenuTokens(Map<String, dynamic> item) {
  Map<String, dynamic> toggleMenu = item[toggle_menu];
  String serviceType = toggleMenu['defaultIcon']['iconType'];
  Map<String, dynamic> libraryAddToken =
      nav(toggleMenu, ['defaultServiceEndpoint', ...feedback_token]);
  Map<String, dynamic> libraryRemoveToken =
      nav(toggleMenu, ['toggledServiceEndpoint', ...feedback_token]);

  if (serviceType == "LIBRARY_REMOVE") {
    // swap if already in library
    Map<String, dynamic> temp = libraryAddToken;
    libraryAddToken = libraryRemoveToken;
    libraryRemoveToken = temp;
  }

  return {'add': libraryAddToken, 'remove': libraryRemoveToken};
}

dynamic nav(dynamic root, List items,
    {bool noneIfAbsent = false, String funName = "d"}) {
  try {
    dynamic res = root;
    for (final item in items) {
      res = res[item];
      //print(res);
    }
    return res;
  } catch (e) {}
}
