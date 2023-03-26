import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/media_Item_builder.dart';
import 'package:hive/hive.dart';

class HomeLibrayController extends GetxController{
  late RxList<MediaItem> cachedSongsList = RxList();
  final isSongFetched = false.obs;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init(){
    //TODO verify from cached directory if song exist or not
    final box = Hive.box("SongsCache");
     cachedSongsList.value = box.values.map<MediaItem?>((item) => MediaItemBuilder.fromJson(item)).whereType<MediaItem>().toList();
     //inspect(cachedSongsList.value);
     isSongFetched.value =true;
  }
}