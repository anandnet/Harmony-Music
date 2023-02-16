import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:harmonymusic/services/utils.dart';
import 'constant.dart';
import 'continuations.dart';
import 'nav_parser.dart';

class MusicServices {
  // ignore: non_constant_identifier_names
  MusicService(){
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
      'client': {"clientName": "WEB_REMIX", "clientVersion": "1.20230213.01.00",'hl':'en'},
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

  

 Future<Response> _sendRequest(String action,Map<dynamic,dynamic> data,{additionalParams=""}) async {
  final response = await dio.post("$baseUrl$action$fixedParms$additionalParams", options: Options(headers:headers,),data: data);

  if(response.statusCode == 200){
    return response;
  }else{
    return _sendRequest(action, data,additionalParams: additionalParams);
  }
 
 } 

  void getSongData({required String videoId}) async {
    try {
      final data = Map.from(context);
      data['video_id'] = videoId;
      final response = await _sendRequest("player", data);
      //print(response.data);
    } on Error catch(e) {
      print(e);
    }
  }

  // Future<List<Map<String, dynamic>>> 
  Future<dynamic> getHome({int limit = 4}) async {
    final data = Map.from(context);
    data["browseId"] = "FEmusic_home";
    final response = await _sendRequest("browse", data);
    final results = nav(response.data, single_column_tab + section_list);
    final home = [...parseMixedContent(results)];

    final sectionList =nav(response.data, single_column_tab + ['sectionListRenderer']);
    //inspect(sectionList);
    //print(sectionList.containsKey('continuations'));
    if (sectionList.containsKey('continuations')) {
      requestFunc(additionalParams) async {
        return (await _sendRequest("browse", data, additionalParams: additionalParams)).data;}
      parseFunc(contents) => parseMixedContent(contents);
  final x = (await getContinuations(sectionList, 'sectionListContinuation',
          limit - home.length,requestFunc, parseFunc));
         // inspect(x);
      home.addAll([...x]) ;
    }

    return home;
  }

}
