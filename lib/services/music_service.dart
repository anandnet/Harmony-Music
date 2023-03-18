import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:harmonymusic/services/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'constant.dart';
import 'continuations.dart';
import 'nav_parser.dart';

enum AudioQuality { High, Medium, Low }

class MusicServices{
  late YoutubeExplode _yt;
  // ignore: non_constant_identifier_names
  MusicServices() {
    init();
  }

  final Map<String, String> _headers = {
    'user-agent': userAgent,
    'accept': '*/*',
    'accept-encoding': 'gzip, deflate',
    'content-type': 'application/json',
    'content-encoding': 'gzip',
    'origin': domain,
    'cookie': 'CONSENT=YES+1',
  };

  final Map<String, dynamic> _context = {
    'context': {
      'client': {
        "clientName": "WEB_REMIX",
        "clientVersion": "1.20230213.01.00",
      },
      'user': {}
    }
  };

  final dio = Dio();

  Future<void> init() async {
    //check visitor id in data base, if not generate one , set lang code
    //headers['X-Goog-Visitor-Id'] = "CgttcW1ucmctbUpITSjXhJ2fBg%3D%3D";
    _context['context']['client']['hl'] = 'en';
    final signatureTimestamp = getDatestamp() - 1;
    _context['playbackContext'] = {
      'contentPlaybackContext': {'signatureTimestamp': signatureTimestamp},
    };
    _headers['X-Goog-Visitor-Id'] = 'CgszaE1mUm55NHNwayjXiamfBg%3D%3D';
    _yt = YoutubeExplode();
  }

  Future<void> genrateVisitorId() async {
    final response = await dio.get(domain, options: Options(headers: _headers));
    final reg = RegExp(r'ytcfg\.set\s*\(\s*({.+?})\s*\)\s*;');
    final matches = reg.firstMatch(response.data.toString());
    String? visitorId;
    if (matches != null) {
      final ytcfg = json.decode(matches.group(1).toString());
      visitorId = ytcfg['VISITOR_DATA']?.toString();
    }
    //print(visitorId);
  }

  Future<Response> _sendRequest(String action, Map<dynamic, dynamic> data,
      {additionalParams = ""}) async {
    //print("$baseUrl$action$fixedParms$additionalParams          data:$data");
    final response =
        await dio.post("$baseUrl$action$fixedParms$additionalParams",
            options: Options(
              headers: _headers,
            ),
            data: data);

    if (response.statusCode == 200) {
      return response;
    } else {
      return _sendRequest(action, data, additionalParams: additionalParams);
    }
  }

  // Future<List<Map<String, dynamic>>>
  Future<dynamic> getHome({int limit = 4}) async {
    final data = Map.from(_context);
    data["browseId"] = "FEmusic_home";
    final response = await _sendRequest("browse", data);
    final results = nav(response.data, single_column_tab + section_list);
    final home = [...parseMixedContent(results)];

    final sectionList =
        nav(response.data, single_column_tab + ['sectionListRenderer']);
    //inspect(sectionList);
    //print(sectionList.containsKey('continuations'));
    if (sectionList.containsKey('continuations')) {
      requestFunc(additionalParams) async {
        return (await _sendRequest("browse", data,
                additionalParams: additionalParams))
            .data;
      }

      parseFunc(contents) => parseMixedContent(contents);
      final x = (await getContinuations(sectionList, 'sectionListContinuation',
          limit - home.length, requestFunc, parseFunc));
      // inspect(x);
      home.addAll([...x]);
    }

    return home;
  }

  Future<Map<String, dynamic>> getWatchPlaylist({
    String videoId = "",
    String playlistId = "",
    int limit = 25,
    bool radio = false,
    bool shuffle = false,
  }) async {
    final data = Map.from(_context);
    data['enablePersistentPlaylistPanel'] = true;
    data['isAudioOnly'] = true;
    data['tunerSettingValue'] = 'AUTOMIX_SETTING_NORMAL';
    if (videoId == "" && playlistId == "") {
      throw Exception(
          "You must provide either a video id, a playlist id, or both");
    }
    if (videoId != "") {
      data['videoId'] = videoId;
      if (playlistId == "") {
        playlistId = "RDAMVM$videoId";
      }

      if (!(radio || shuffle)) {
        data['watchEndpointMusicSupportedConfigs'] = {
          'watchEndpointMusicConfig': {
            'hasPersistentPlaylistPanel': true,
            'musicVideoType': "MUSIC_VIDEO_TYPE_ATV",
          }
        };
      }
    }

    playlistId = validatePlaylistId(playlistId);
    data['playlistId'] = playlistId;
    final isPlaylist =
        playlistId.startsWith('PL') || playlistId.startsWith('OLA');
    if (shuffle) {
      data['params'] = "wAEB8gECKAE%3D";
    }
    if (radio) {
      data['params'] = "wAEB";
    }
    final response = (await _sendRequest("next", data)).data;
    inspect(response);
    final watchNextRenderer = nav(response, [
      'contents',
      'singleColumnMusicWatchNextResultsRenderer',
      'tabbedRenderer',
      'watchNextTabbedResultsRenderer'
    ]);

    final lyricsBrowseId = getTabBrowseId(watchNextRenderer, 1);
    final relatedBrowseId = getTabBrowseId(watchNextRenderer, 2);

    final results = nav(watchNextRenderer, [
      ...tab_content,
      'musicQueueRenderer',
      'content',
      'playlistPanelRenderer'
    ]);
    final playlist = results['contents']
        .map((content) => nav(
            content, ['playlistPanelVideoRenderer', ...navigation_playlist_id]))
        .where((e) => e != null)
        .toList()
        .first;
    final tracks = parseWatchPlaylist(results['contents']);

    // if (results.containsKey('continuations')) {
    //   requestFunc(additionalParams) async =>
    //       (await _sendRequest("next", data, additionalParams: additionalParams))
    //           .data;
    //   parseFunc(contents) => parseWatchPlaylist(contents);
    //   final x = await getContinuations(results, 'playlistPanelContinuation',
    //       limit - tracks.length, requestFunc, parseFunc,
    //       ctokenPath: isPlaylist ? '' : 'Radio');
    //   tracks.addAll([...x]);
    // }

    return {
      'tracks': tracks,
      'playlistId': playlist,
      'lyrics': lyricsBrowseId,
      'related': relatedBrowseId
    };
  }

  Future<Map<String, dynamic>> getPlaylistSongs(String playlistId,
      {int limit = 100, bool related = false, int suggestionsLimit = 0}) async {
    String browseId =
        playlistId.startsWith("VL") ? playlistId : "VL$playlistId";
    final data = Map.from(_context);
    data['browseId'] = browseId;
    Map<String, dynamic> response = (await _sendRequest('browse', data)).data;
    Map<String, dynamic> header = response['header'];
    Map<String, dynamic> results = nav(response,
        single_column_tab + section_list_item + ['musicPlaylistShelfRenderer']);
    Map<String, dynamic> playlist = {'id': results['playlistId']};

    bool ownPlaylist =
        header.containsKey('musicEditablePlaylistDetailHeaderRenderer');
    if (!ownPlaylist) {
      playlist['privacy'] = 'PUBLIC';
      header = header['musicDetailHeaderRenderer'];
    } else {
      Map<String, dynamic> editableHeader =
          header['musicEditablePlaylistDetailHeaderRenderer'];
      playlist['privacy'] = editableHeader['editHeader']
          ['musicPlaylistEditHeaderRenderer']['privacy'];
      header = editableHeader['header']['musicDetailHeaderRenderer'];
    }

    playlist['title'] = nav(header, title_text);
    playlist['thumbnails'] = nav(header, thumnail_cropped);
    playlist["description"] = nav(header, description);
    int runCount = header['subtitle']['runs'].length;
    if (runCount > 1) {
      playlist['author'] = {
        'name': nav(header, subtitle2),
        'id': nav(header, ['subtitle', 'runs', 2] + navigation_browse_id)
      };
      if (runCount == 5) {
        playlist['year'] = nav(header, subtitle3);
      }
    }

    int songCount = int.parse(RegExp(r'([\d,]+)')
        .stringMatch(header['secondSubtitle']['runs'][0]['text'])!);
    if (header['secondSubtitle']['runs'].length > 1) {
      playlist['duration'] = header['secondSubtitle']['runs'][2]['text'];
    }

    playlist['trackCount'] = songCount;

    requestFunc(additionalParams) async =>
        (await _sendRequest("browse", data, additionalParams: additionalParams))
            .data;

    // // suggestions and related are missing e.g. on liked songs
    // Map<String, dynamic> sectionList = nav(response, single_column_tab + ['sectionListRenderer']);
//   if (sectionList.containsKey('continuations')) {
//     String additionalParams = getContinuationParams(sectionList);
//     if (ownPlaylist && (suggestionsLimit > 0 || related)) {
//       parseFunc(results) => parsePlaylistItems(results);
//       Map<String, dynamic> suggested = await requestFunc(additionalParams);
//       Map<String, dynamic> continuation = nav(suggested, SECTION_LIST_CONTINUATION);
//       additionalParams = getContinuationParams(continuation);
//       Map<String, dynamic> suggestionsShelf = nav(continuation, CONTENT + MUSIC_SHELF);
//       playlist['suggestions'] = getContinuationContents(suggestionsShelf, parseFunc);

//       playlist['suggestions'].addAll(await getContinuations(suggestionsShelf,
//                                                             'musicShelfContinuation',
//                                                             suggestionsLimit - (playlist['suggestions']).length,
//                                                             requestFunc,
//                                                             parseFunc,
//                                                             reloadable: true));

//     }
//      if (related) {
//     var response = requestFunc(additionalParams);
//     var continuation = nav(response, SECTION_LIST_CONTINUATION);
//     parseFunc = (results) => parseContentList(results, parsePlaylist);
//     playlist['related'] = getContinuationContents(nav(continuation, CONTENT + CAROUSEL), parseFunc);
//   }
// }

    if (songCount > 0) {
      playlist['tracks'] = parsePlaylistItems(results['contents']);
      limit ??= songCount;
      var songsToGet = min(limit, songCount);

      List<dynamic> parseFunc(contents) => parsePlaylistItems(contents);
      if (results.containsKey('continuations')) {
        (playlist['tracks'] as List<dynamic>).addAll(await getContinuations(
            results,
            'musicPlaylistShelfContinuation',
            songsToGet - (playlist['tracks']).length as int,
            requestFunc,
            parseFunc));
      }
    }
    playlist['duration_seconds'] = sumTotalDuration(playlist);
    return playlist;
  }

  Future<Uri?> getSongUri(String songId,
      {AudioQuality quality = AudioQuality.Low}) async {
    try {
      final songStreamManifest =
          await _yt.videos.streamsClient.getManifest(songId);
      final streamUriList = songStreamManifest.audioOnly.sortByBitrate();
      if (quality == AudioQuality.High) {
        return songStreamManifest.audioOnly.withHighestBitrate().url;
      } else if (quality == AudioQuality.Medium) {
        return streamUriList[streamUriList.length ~/ 2].url;
      } else {
        return streamUriList[0].url;
      }
    } catch (e) {
      return null;
    }
  }

//  Future<Uri> getSongUri(String songId) async {
//     final response =
//         await Dio().get("https://watchapi.whatever.social/streams/$songId");
//     if (response.statusCode == 200) {
//       final responseUrl = ((response.data["audioStreams"])
//           .firstWhere((val) => val["quality"] == "48 kbps"))["url"];
//           print("hello");
//       return Uri.parse(responseUrl);
//     } else {
//       return getSongUri(songId);
//     }
//   }
}
