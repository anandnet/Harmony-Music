import 'package:get/get.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreenController extends GetxController {
  final cacheSongs = false.obs;
  final setBox = Hive.box("AppPrefs");
  final themeModetype = ThemeType.dynamic.obs;
  final skipSilenceEnabled = false.obs;
  final streamingQuality = AudioQuality.High.obs;
  @override
  void onInit() {
    _setInitValue();
    super.onInit();
  }

  void _setInitValue() {
    cacheSongs.value = setBox.get('cacheSongs');
    themeModetype.value = ThemeType.values[setBox.get('themeModeType')];
    skipSilenceEnabled.value = setBox.get("skipSilenceEnabled");
    streamingQuality.value =
        AudioQuality.values[setBox.get('streamingQuality')];
  }

  void setStreamingQuality(dynamic val) {
    setBox.put("streamingQuality", AudioQuality.values.indexOf(val));
    streamingQuality.value = val;
  }

  void onThemeChange(dynamic val) {
    setBox.put('themeModeType', ThemeType.values.indexOf(val));
    themeModetype.value = val;
    Get.find<ThemeController>().changeThemeModeType(val);
  }

  void toggleCachingSongsValue(bool value) {
    setBox.put("cacheSongs", value);
    cacheSongs.value = value;
  }

  void toggleSkipSilence(bool val) {
    Get.find<PlayerController>().toggleSkipSilence(val);
    setBox.put('skipSilenceEnabled', val);
    skipSilenceEnabled.value = val;
  }
}
