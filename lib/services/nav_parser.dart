//navigations
// ignore_for_file: constant_identifier_names, empty_catches

import 'package:audio_service/audio_service.dart';

import '/models/media_Item_builder.dart';
import '/services/utils.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../models/playlist.dart';

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
const audio_watch_playlist_id = [
  ...menu_items,
  0,
  'menuNavigationItemRenderer',
  ...navigation_watch_playlist_id
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
const subtitle = ['subtitle', 'runs', 0, 'text'];
const subtitle3 = ['subtitle', 'runs', 4, 'text'];
const feedback_token = ['feedbackEndpoint', 'feedbackToken'];
const musicPlaylistShelfRenderer = [
  "contents",
  "twoColumnBrowseResultsRenderer",
  "secondaryContents",
  "sectionListRenderer",
  "contents",
  0,
  "musicPlaylistShelfRenderer",
];

List<Map<String, dynamic>> parseMixedContent(List<dynamic> rows) {
  List<Map<String, dynamic>> items = [];
  //inspect(rows);

  for (var row in rows) {
    dynamic title;
    dynamic contents = [];
    if (description_shelf[0] == row.keys.first.toString()) {
      var results = nav(row, description_shelf);
      title = nav(results, ['header', 'runs', 0, 'text']);
      contents = nav(results, description);
    } else {
      var results = row.values.first;
      if (!results.containsKey('contents')) {
        continue;
      }
      title = nav(results, carousel_title + ['text']);

      for (var result in results['contents']) {
        var data = nav(result, [mtrir]);
        dynamic content;
        if (data != null) {
          var pageType = nav(data, n_title + navigation_browse + page_type,
              noneIfAbsent: true, funName: "mixed1");
          if (pageType == null) {
            if (nav(data, navigation_watch_playlist_id) != null) {
              //  content = parseWatchPlaylistHome(data);
            } else {
              content = parseSong(data);
            }
          } else if (pageType == "MUSIC_PAGE_TYPE_ALBUM") {
            content = parseAlbum(data, reqAlbumObj: false);
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

dynamic parseVideo(dynamic result) {
  final runs = nav(result, ['subtitle', 'runs']);
  final runsLength = runs.length;
  final artistsLen = runsLength == 3 ? 1 : getDotSeparatorIndex(runs);
  return MediaItemBuilder.fromJson({
    'title': nav(result, title_text),
    'videoId': nav(result, navigation_video_id) ??
        nav(
          result,
          navigation_browse_id,
        ),
    'artists': parseSongArtistsRuns(runs.sublist(0, artistsLen)),
    'playlistId': nav(result, navigation_playlist_id),
    'thumbnails': nav(result, thumbnail_renderer),
    'views': runs[runs.length - 1]['text'].split(' ')[0]
  });
}

dynamic parseSingle(dynamic result) {
  dynamic year;
  try {
    year = int.parse(nav(result, subtitle));
  } catch (e) {
    year = nav(result, ["subtitle", "runs", 2, "text"]);
  }
  return Album.fromJson({
    'title': nav(result, title_text),
    'artists': [
      {'name': 'Single'}
    ],
    'audioPlaylistId': nav(result, audio_watch_playlist_id),
    'year': "${year ?? ""}",
    'browseId': nav(result, ['title', 'runs', 0, ...navigation_browse_id]),
    'thumbnails': nav(result, thumbnail_renderer),
    'description':
        (nav(result, ["subtitle", "runs"])).map((run) => run['text']).join('')
  });
}

MediaItem parseSong(Map<dynamic, dynamic> result) {
  //inspect(result);
  var song = {
    'title': nav(result, title_text),
    'videoId':
        nav(result, navigation_video_id) ?? nav(result, navigation_browse_id),
    'playlistId': nav(result, navigation_playlist_id,
        noneIfAbsent: true, funName: "parseSong"),
    'thumbnails': nav(result, thumbnail_renderer),
  };

  song.addAll(parseSongRuns(result['subtitle']['runs']));
  return MediaItemBuilder.fromJson(song);
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
      RegExp regExp = RegExp(r"^\d([^ ])* [^ ]*$");
      if (regExp.hasMatch(text) && i > 0) {
        parsed['views'] = text.split(' ')[0];
      } else if (RegExp(r"^(\d+:)*\d+:\d+$").hasMatch(text)) {
        parsed['length'] = text;
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

Album parseAlbum(Map<dynamic, dynamic> result, {bool reqAlbumObj = true}) {
  final List runs = nav(result, ['subtitle', 'runs']);
  final Map<String, dynamic> artistInfo = parseSongRuns(runs);
  Map albumMap = {
    'title': nav(result, title_text),
    'browseId': nav(result, n_title + navigation_browse_id),
    'thumbnails': nav(result, thumbnail_renderer),
    'audioPlaylistId': nav(result, audio_watch_playlist_id),
    'description':
        (nav(result, ["subtitle", "runs"])).map((run) => run['text']).join('')
    //'isExplicit': nav(result, subtitle_badge_label, noneIfAbsent: true) != null,
  };
  albumMap.addAll(artistInfo);
  return Album.fromJson(albumMap);
}

Artist parseRelatedArtist(Map<String, dynamic> data) {
  return Artist.fromJson({
    'artist': nav(data, title_text),
    'browseId': nav(data, n_title + navigation_browse_id),
    'thumbnails': nav(data, thumbnail_renderer),
  });
}

Playlist parsePlaylist(Map<String, dynamic> data) {
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

  return Playlist.fromJson(playlist);
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

MediaItem parseSongFlat(Map<String, dynamic> data) {
  //print(data);
  List<Map<String, dynamic>> columns = [];
  for (int i = 0; i < data['flexColumns'].length; i++) {
    columns.add(getFlexColumnItem(data, i));
  }

  Map<String, dynamic> song = {
    'title': nav(columns[0], text_run_text),
    'videoId': nav(columns[0], text_run + navigation_video_id,
            noneIfAbsent: true, funName: "parseSongFlat") ??
        nav(columns[0], text_run + navigation_browse_id,
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

  return MediaItemBuilder.fromJson(song);
}

List<dynamic>? parseSongArtists(Map<String, dynamic> data, int index) {
  dynamic flexItem = getFlexColumnItem(data, index);
  if (flexItem == null || flexItem.length == 0) {
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
  final tracks = [];
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
    tracks.add(MediaItemBuilder.fromJson(track));
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

///Parse playlist songs, Also used in Album Song parsing
///
///[dynamic album,dynamic artists] used in Album case
List<dynamic> parsePlaylistItems(List<dynamic> results,
    {List<List<dynamic>>? menuEntries,
    dynamic thumbnailsM,
    dynamic artistsM,
    String? albumYear,
    dynamic albumIdName,
    bool isAlbum = false}) {
  List<MediaItem> songs = [];

  //int count = 1;
  for (dynamic result in results) {
    // count += 1;
    if (!result.containsKey('musicResponsiveListItemRenderer')) {
      continue;
    }
    dynamic data = result['musicResponsiveListItemRenderer'];
    String? videoId;
    String? trackDetails;

    videoId = nav(data, ['playlistItemData', 'videoId']);

    if (videoId == null && isAlbum) {
      final creditId = nav(data, [
        'menu',
        'menuRenderer',
        'items',
        5,
        'menuNavigationItemRenderer',
        'navigationEndpoint',
        'browseEndpoint',
        'browseId'
      ]);
      videoId = creditId?.split("MPTC")[1];
      
    }

    if(isAlbum){
      // Contains track number and total tracks 
      trackDetails = data?["index"] != null
          ? "${nav(data, ['index', 'runs', 0, 'text'])}/${results.length}"
          : null;
    }

    // if the item has a menu, find its setVideoId
    if (videoId == null) {
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
    }

    // if item is not playable, the videoId was retrieved above
    if (videoId == null && nav(data, play_button) != null) {
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

    dynamic album = isAlbum ? albumIdName : parseSongAlbum({...data}, 2);

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
      'album': album,
      'artists': artists ?? artistsM,
      'thumbnails': isAlbum ? thumbnailsM : thumbnails_ ?? thumbnailsM,
      'isAvailable': isAvailable,
      'trackDetails': trackDetails
    };

    if (duration != null) {
      song['length'] = duration;
      song['duration_seconds'] = parseDuration(duration);
    }

    if (menuEntries != null) {
      for (final List<dynamic> menuEntry in menuEntries) {
        song[menuEntry.last] = nav(data,
            menu_items + menuEntry.map((e) => e).whereType<String>().toList());
      }
    }
    if (song['videoId'] != null) {
      songs.add(MediaItemBuilder.fromJson(song));
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
    }
    return res;
  } catch (e) {
    return null;
  }
}

//search parsers
dynamic parseTopResult(
    Map<String, dynamic> data, List<String> searchResultTypes) {
  Map<String, dynamic> searchResult = {};
  String? resultType =
      getSearchResultType(nav(data, subtitle), searchResultTypes);
  searchResult['resultType'] = resultType;

  if (resultType == 'artist') {
    String? subscribers = nav(data, subtitle2);
    if (subscribers != null) {
      searchResult['subscribers'] = subscribers.split(' ')[0];
    }
    Map<String, dynamic> artistInfo =
        parseSongRuns(nav(data, ['title', 'runs']));
    searchResult.addAll(artistInfo);
  }

  if (resultType == 'song' || resultType == 'video' || resultType == 'album') {
    searchResult['title'] = nav(data, title_text);
    List runs = nav(data, ['subtitle', 'runs']);
    List songInfoRuns = runs.sublist(2);
    Map<String, dynamic> songInfo = parseSongRuns(songInfoRuns);
    searchResult.addAll(songInfo);
  }

  searchResult['thumbnails'] = nav(data, thumbnails);

  if (resultType == 'song' || resultType == 'video') {
    return MediaItemBuilder.fromJson(searchResult);
  } else if (resultType == 'playlist') {
    return Playlist.fromJson(searchResult);
  } else if (resultType == 'album') {
    return Album.fromJson(searchResult);
  } else if (resultType == 'Artist') {
    return Artist.fromJson(searchResult);
  }
  return searchResult;
}

String? getSearchResultType(
    String? resultTypeLocal, List<String> resultTypesLocal) {
  if (resultTypeLocal == null) {
    return null;
  }
  List<String> resultTypes = ['artist', 'playlist', 'song', 'video', 'station'];
  resultTypeLocal = resultTypeLocal.toLowerCase();
  if (!resultTypesLocal.contains(resultTypeLocal)) {
    return 'album';
  } else {
    int index = resultTypesLocal.indexOf(resultTypeLocal);
    return resultTypes[index];
  }
}

List<dynamic> parseSearchResults(List<dynamic> results,
    List<String> searchResultTypes, String? resultType, String category) {
  return results
      .map((result) {
        return parseSearchResult(result['musicResponsiveListItemRenderer'],
            searchResultTypes, resultType, category);
      })
      .whereType<dynamic>()
      .toList();
}

dynamic parseSearchResult(Map<String, dynamic> data,
    List<String> searchResultTypes, String? resultType, String category) {
  if ((resultType != null && resultType.contains("playlist")) ||
      category.contains("playlists")) {
    resultType = 'playlist';
  }
  int defaultOffset = (resultType == null) ? 2 : 0;
  Map<String, dynamic> searchResult = {'category': category};
  String? videoType = nav(data,
      [...play_button, 'playNavigationEndpoint', ...navigation_video_type]);
  if (videoType != null) {
    resultType = (videoType == 'MUSIC_VIDEO_TYPE_ATV') ? 'song' : 'video';
  }

  resultType = ((resultType == null)
      ? getSearchResultType(getItemText(data, 1), searchResultTypes)
      : resultType)!;
  searchResult['resultType'] = resultType;

  if (resultType != 'artist') {
    searchResult['title'] = getItemText(data, 0);
  }

  if (resultType == 'artist') {
    searchResult['artist'] = getItemText(data, 0);
    final list = data['flexColumns'][1]
        ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'];
    searchResult['subscribers'] = list.length < 2 ? "" : list[2];
    ['text'];
    //final x = parseMenuPlaylists(data, searchResult);
  } else if (resultType == 'album') {
    searchResult['type'] = getItemText(data, 1);
    searchResult['audioPlaylistId'] = nav(data, audio_watch_playlist_id);
    try {
      final list = data['flexColumns'][1]
          ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'];
      searchResult['description'] = list.map((run) => run['text']).join('');
    } catch (e) {}
  } else if (resultType.contains('playlist')) {
    List<dynamic> flexItem = getFlexColumnItem(data, 1)['text']['runs'];
    bool hasAuthor = (flexItem.length == defaultOffset + 3);
    searchResult['itemCount'] =
        nav(flexItem, [defaultOffset + (hasAuthor ? 2 : 0), 'text'])
            .split(' ')[0];
    searchResult['description'] =
        hasAuthor ? nav(flexItem, [defaultOffset, 'text']) : null;
  } else if (resultType == 'station') {
    searchResult['videoId'] =
        nav(data, navigation_video_id) ?? nav(data, navigation_browse_id);
    searchResult['playlistId'] = nav(data, navigation_playlist_id);
  } else if (resultType == 'song') {
    searchResult['album'] = null;
  } else if (resultType == 'upload') {
    String? browseId = nav(data, navigation_browse_id);
    if (browseId == null) {
      List<dynamic> flexItems = [
        nav(getFlexColumnItem(data, 0), ['text', 'runs']),
        nav(getFlexColumnItem(data, 1), ['text', 'runs'])
      ];
      if (flexItems[0] != null) {
        searchResult['videoId'] = nav(flexItems[0][0], navigation_video_id) ??
            nav(flexItems[0][0], navigation_browse_id);
        searchResult['playlistId'] =
            nav(flexItems[0][0], navigation_playlist_id);
      }
      if (flexItems[1] != null) {
        searchResult.addAll(parseSongRuns(flexItems[1]));
      }
      searchResult['resultType'] = 'song';
    } else {
      searchResult['browseId'] = browseId;
      if (searchResult['browseId'].contains('artist')) {
        searchResult['resultType'] = 'artist';
      } else {
        Map<String, dynamic> flexItem2 = getFlexColumnItem(data, 1);
        List<dynamic> runs = [
          for (int i = 0; i < flexItem2['text']['runs'].length; i++)
            if (i % 2 == 0) flexItem2['text']['runs'][i]['text']
        ];
        if (runs.length > 1) {
          searchResult['artist'] = runs[1];
        }
        if (runs.length > 2) {
          searchResult['releaseDate'] = runs[2];
        }
        searchResult['resultType'] = 'album';
      }
    }
  }
  if ((['song', 'video']).contains(resultType)) {
    searchResult['videoId'] = nav(data,
        [...play_button, 'playNavigationEndpoint', 'watchEndpoint', 'videoId']);
    searchResult['videoType'] = videoType;
  }

  if ((['song', 'video', 'album']).contains(resultType)) {
    searchResult['length'] = null;
    searchResult['year'] = null;
    final flexItem = getFlexColumnItem(data, 1);
    final runs = (flexItem['text']['runs']);
    final songInfo = parseSongRuns(runs);
    searchResult.addAll(songInfo);
  }

  if ((['artist', 'album', 'playlist']).contains(resultType)) {
    searchResult['browseId'] = nav(data, navigation_browse_id);
    if (searchResult['browseId'] == null) {
      return {};
    }
  }

  if ((['song', 'album']).contains(resultType)) {
    searchResult['isExplicit'] = nav(data, badge_label);
  }

  searchResult['thumbnails'] = nav(data, thumbnails);

  if (resultType == 'song' || resultType == 'video') {
    if (searchResult['videoId'] != null) {
      return MediaItemBuilder.fromJson(searchResult);
    }
    return;
  } else if (resultType.contains('playlist')) {
    return Playlist.fromJson(searchResult);
  } else if (resultType == 'album') {
    return Album.fromJson(searchResult);
  } else if (resultType == 'artist') {
    return Artist.fromJson(searchResult);
  }

  return searchResult;
}

//parse album Header
Map<String, dynamic> parseAlbumHeader(Map<String, dynamic> response) {
  Map<String, dynamic> header = nav(response, [
        'contents',
        "twoColumnBrowseResultsRenderer",
        'tabs',
        0,
        "tabRenderer",
        "content",
        "sectionListRenderer",
        "contents",
        0,
        "musicResponsiveHeaderRenderer"
      ]) ??
      nav(response, ["header", "musicDetailHeaderRenderer"]);
  Map<String, dynamic> album = {
    'title': nav(header, title_text),
    'type': nav(header, subtitle),
    'thumbnails': nav(header, thumnail_cropped) ??
        nav(header,
            ["thumbnail", "musicThumbnailRenderer", "thumbnail", "thumbnails"])
  };

  album["description"] = nav(header, [
        "description",
        "musicDescriptionShelfRenderer",
        "description",
        "runs",
        0,
        "text"
      ]) ??
      (nav(header, ["subtitle", "runs"]))
          .map((item) => item.values.first)
          .toList()
          .join(" ");

  Map<String, dynamic> albumInfo =
      parseSongRuns(header['subtitle']['runs'].sublist(2));
  try {
    albumInfo.addAll(parseSongRuns(header["straplineTextOne"]['runs']));
  } catch (e) {}
  album.addAll(albumInfo);

  if (header['secondSubtitle']['runs'].length > 1) {
    album['trackCount'] = (header['secondSubtitle']['runs'][0]['text']);
    album['duration'] = header['secondSubtitle']['runs'][2]['text'];
  } else {
    album['duration'] = header['secondSubtitle']['runs'][0]['text'];
  }

  // add to library/uploaded

  album['audioPlaylistId'] =
      nav(response, ['microformat', "microformatDataRenderer", "urlCanonical"])
          .toString()
          .split("list=")[1];

  return album;
}

Map<String, dynamic> parseArtistContents(List results) {
  final Map<String, dynamic> navigationEndpointsNContent = {
    'Songs': null,
    'Videos': null,
    'Albums': null,
    'Singles': null
  };

  for (dynamic result in results) {
    if (result.containsKey('musicShelfRenderer')) {
      final title =
          nav(result, ['musicShelfRenderer', 'title', 'runs', 0])['text'];
      final browseEndpoint = nav(
          result, ['musicShelfRenderer', 'bottomEndpoint', 'browseEndpoint']);

      final contentList = nav(result, ['musicShelfRenderer', 'contents']);
      final content = parsePlaylistItems(contentList);

      if (browseEndpoint == null) {
        navigationEndpointsNContent[title] = {"content": content};
      } else {
        navigationEndpointsNContent[title] = {
          'browseId': browseEndpoint['browseId'],
          'params': browseEndpoint['params'],
          "content": content
        };
      }
    } else if (result.containsKey('musicCarouselShelfRenderer')) {
      final browseEndpoint = nav(result, [
        'musicCarouselShelfRenderer',
        'header',
        'musicCarouselShelfBasicHeaderRenderer',
        'moreContentButton',
        'buttonRenderer',
        'navigationEndpoint',
        'browseEndpoint'
      ]);

      final title = nav(result, [
        'musicCarouselShelfRenderer',
        'header',
        'musicCarouselShelfBasicHeaderRenderer',
        'title',
        'runs',
        0
      ])['text'];

      final contentList =
          nav(result, ['musicCarouselShelfRenderer', 'contents']);
      dynamic content = [];
      if (title == "Videos") {
        content = contentList
            .map((video) => parseVideo(video['musicTwoRowItemRenderer']))
            .toList();
      } else if (title == "Albums") {
        content = contentList
            .map((album) => parseAlbum(album['musicTwoRowItemRenderer']))
            .toList();
      } else if (title == "Singles") {
        content = contentList
            .map((single) => parseSingle(single['musicTwoRowItemRenderer']))
            .toList();
      }

      if (browseEndpoint != null) {
        navigationEndpointsNContent[title] = {
          'browseId': browseEndpoint['browseId'],
          'params': browseEndpoint['params'],
          'content': content
        };
      } else {
        navigationEndpointsNContent[title] = {'content': content};
      }
    }
  }
  return navigationEndpointsNContent;
}

dynamic parseContentList(results, Function parseFunc) {
  var contents = [];
  for (dynamic result in results) {
    contents.add(parseFunc(result['musicTwoRowItemRenderer']));
  }

  return contents;
}

Map<String, dynamic> parseChartsItem(dynamic result) {
  final contentList = nav(result, ['musicCarouselShelfRenderer', 'contents']);
  final String category = nav(result, [
    'musicCarouselShelfRenderer',
    'header',
    'musicCarouselShelfBasicHeaderRenderer',
    'title',
    ...run_text
  ]);
  if (category.contains('videos')) {
    final videoList = contentList
        .map((video) => parseVideo(video['musicTwoRowItemRenderer']))
        .toList();
    return {'title': category, 'contents': videoList};
  } else if (category.contains('artists')) {
    final artists = contentList
        .map((artist) =>
            parseChartsArtist(artist['musicResponsiveListItemRenderer']))
        .toList();
    return {'title': category, 'contents': artists};
  } else if (category.contains('Genres')) {
    final playlists = contentList
        .map((playlist) => parsePlaylist(playlist['musicTwoRowItemRenderer']))
        .toList();
    return {'title': category, 'contents': playlists};
  } else if (category.contains('Trending')) {
    final videoList = contentList
        .map((video) =>
            parseChartsTrending(video['musicResponsiveListItemRenderer']))
        .whereType<MediaItem>()
        .toList();
    return {'title': category, 'contents': videoList};
  }
  return {};
}

Artist parseChartsArtist(dynamic data) {
  final subscribers = getFlexColumnItem(data, 1);
  dynamic subs;
  if (subscribers.isNotEmpty) {
    subs = nav(subscribers, text_run_text).split(' ')[0];
  }

  final parsed = {
    'artist': nav(getFlexColumnItem(data, 0), text_run_text),
    'browseId': nav(data, navigation_browse_id),
    'subscribers': subs,
    'thumbnails': nav(data, thumbnails),
  };

  return Artist.fromJson(parsed);
}

MediaItem? parseChartsTrending(dynamic data) {
  final flex_0 = getFlexColumnItem(data, 0);
  final artists = parseSongArtists(data, 1);

  final video = {
    'title': nav(flex_0, text_run_text),
    'videoId': nav(
          flex_0,
          text_run + navigation_video_id,
        ) ??
        nav(data, ['playlistItemData', 'videoId']),
    'playlistId': nav(flex_0, text_run + navigation_playlist_id),
    'artists': artists,
    'thumbnails': nav(data, thumbnails),
  };
  if (video['videoId'] == null) {
    return null;
  }
  return MediaItemBuilder.fromJson(video);
}
