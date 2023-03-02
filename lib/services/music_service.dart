import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:harmonymusic/services/utils.dart';
import 'constant.dart';
import 'continuations.dart';
import 'nav_parser.dart';

class MusicServices {
  // ignore: non_constant_identifier_names
  MusicService() {
    init();
  }

  Map<String, String> headers = {
    'user-agent': userAgent,
    'accept': '*/*',
    'accept-encoding': 'gzip, deflate',
    'content-type': 'application/json',
    'content-encoding': 'gzip',
    'origin': domain,
    'cookie': 'CONSENT=YES+1',
    'X-Goog-Visitor-Id': 'CgszaE1mUm55NHNwayjXiamfBg%3D%3D'
  };

  Map<String, dynamic> context = {
    'context': {
      'client': {
        "clientName": "WEB_REMIX",
        "clientVersion": "1.20230213.01.00",
        'hl': 'en'
      },
      'user': {}
    }
  };

  final dio = Dio();

  Future<void> init() async {
    //check visitor id in data base, if not generate one , set lang code
    //headers['X-Goog-Visitor-Id'] = "CgttcW1ucmctbUpITSjXhJ2fBg%3D%3D";
    context['context']['client']['hl'] = 'en';
    final signatureTimestamp = getDatestamp() - 1;
    context['playbackContext'] = {
      'contentPlaybackContext': {'signatureTimestamp': signatureTimestamp},
    };
  }

  Future<void> genrateVisitorId() async {
    final response = await dio.get(domain, options: Options(headers: headers));
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
              headers: headers,
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
    final data = Map.from(context);
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
    String videoId="",
    String playlistId ="",
    int limit = 25,
    bool radio = false,
    bool shuffle = false,
  }) async {
    final data = Map.from(context);
    data['enablePersistentPlaylistPanel'] = true;
    data['isAudioOnly'] = true;
    data['tunerSettingValue'] ='AUTOMIX_SETTING_NORMAL';
    if (videoId == "" && playlistId == "") {
      throw Exception(
          "You must provide either a video id, a playlist id, or both");
    }
    if (videoId != "") {
      data['videoId'] = videoId;
      if(playlistId == ""){
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
    final isPlaylist = playlistId.startsWith('PL') || playlistId.startsWith('OLA');
    if (shuffle) {
      data['params'] = "wAEB8gECKAE%3D";
    }
    if (radio) {
      data['params'] = "wAEB";
    }
    final response = (await _sendRequest("next", data)).data;
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
}
