import 'package:android_power_manager/android_power_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../utils/update_check_flag_file.dart';
import '/services/piped_service.dart';
import '/ui/utils/home_library_controller.dart';
import '../widgets/snackbar.dart';
import '../../utils/helper.dart';
import '/services/music_service.dart';
import '/ui/player/player_controller.dart';
import '/ui/screens/home_screen_controller.dart';
import '/ui/utils/theme_controller.dart';

class SettingsScreenController extends GetxController {
  final cacheSongs = false.obs;
  final setBox = Hive.box("AppPrefs");
  final themeModetype = ThemeType.dynamic.obs;
  final skipSilenceEnabled = false.obs;
  final streamingQuality = AudioQuality.High.obs;
  final isIgnoringBatteryOptimizations = false.obs;
  final discoverContentType = "QP".obs;
  final isNewVersionAvailable = false.obs;
  final isLinkedWithPiped = false.obs;
  final stopPlyabackOnSwipeAway = false.obs;
  final currentVersion = "V1.5.0";

  @override
  void onInit() {
    _setInitValue();
     if(updateCheckFlag) _checkNewVersion();
    super.onInit();
  }

  get currentVision => currentVersion;

  _checkNewVersion() {
    newVersionCheck(currentVersion)
        .then((value) => isNewVersionAvailable.value = value);
  }

  Future<void> _setInitValue() async {
    cacheSongs.value = setBox.get('cacheSongs');
    themeModetype.value = ThemeType.values[setBox.get('themeModeType')];
    skipSilenceEnabled.value = setBox.get("skipSilenceEnabled");
    streamingQuality.value =
        AudioQuality.values[setBox.get('streamingQuality')];
    discoverContentType.value = setBox.get('discoverContentType') ?? "QP";
    if (setBox.containsKey("piped")) {
      isLinkedWithPiped.value = setBox.get("piped")['isLoggedIn'];
    }
    stopPlyabackOnSwipeAway.value =
        setBox.get('stopPlyabackOnSwipeAway') ?? false;
    if (GetPlatform.isAndroid) {
      isIgnoringBatteryOptimizations.value =
          (await AndroidPowerManager.isIgnoringBatteryOptimizations)!;
    }
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

  void onContentChange(dynamic value) {
    setBox.put('discoverContentType', value);
    discoverContentType.value = value;
    Get.find<HomeScreenController>().changeDiscoverContent(value);
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

  Future<void> enableIgnoringBatteryOptimizations() async {
    await AndroidPowerManager.requestIgnoreBatteryOptimizations();
    isIgnoringBatteryOptimizations.value =
        (await AndroidPowerManager.isIgnoringBatteryOptimizations)!;
  }

  Future<void> unlinkPiped() async {
    Get.find<PipedServices>().logout();
    isLinkedWithPiped.value = false;
    Get.find<LibraryPlaylistsController>().removePipedPlaylists();
    final box = await Hive.openBox('blacklistedPlaylist');
    box.clear();
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
        Get.context!, "Unlinked successfully!",
        size: SanckBarSize.MEDIUM));
    box.close();
  }

  void toggleStopPlyabackOnSwipeAway(bool val) {
    setBox.put('stopPlyabackOnSwipeAway', val);
    stopPlyabackOnSwipeAway.value = val;
  }
}
