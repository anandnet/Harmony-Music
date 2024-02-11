import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import '../ui/screens/Home/home_screen_controller.dart';

class DesktopSystemTray extends GetxService {
  late WindowListener listener;

  @override
  void onInit() {
    Future.delayed(const Duration(seconds: 2), () => initSystemTray());
    super.onInit();
  }

  Future<void> initSystemTray() async {
    String path = GetPlatform.isWindows
        ? 'assets/icons/icon.ico'
        : 'assets/icons/icon.png';

    await windowManager.ensureInitialized();
    final SystemTray systemTray = SystemTray();
    final playerController = Get.find<PlayerController>();

    // We first init the systray menu
    await systemTray.initSystemTray(
      title: "system tray",
      iconPath: path,
    );

    // create context menu
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
          label: 'Show/Hide',
          onClicked: (menuItem) async => await windowManager.isVisible()
              ? await windowManager.hide()
              : await windowManager.show()),
      MenuSeparator(),
      MenuItemLabel(
          label: 'Prev',
          onClicked: (menuItem) {
            if (playerController.currentQueue.isNotEmpty) {
              playerController.prev();
            }
          }),
      MenuItemLabel(
          label: 'Play/Pause',
          onClicked: (menuItem) {
            if (playerController.currentQueue.isNotEmpty) {
              playerController.playPause();
            }
          }),
      MenuItemLabel(
          label: 'Next',
          onClicked: (menuItem) {
            if (playerController.currentQueue.isNotEmpty) {
              playerController.next();
            }
          }),
      MenuSeparator(),
      MenuItemLabel(
          label: 'Quit',
          onClicked: (menuItem) async {
            if (Get.find<SettingsScreenController>()
                .restorePlaybackSession
                .isTrue) {
              await Get.find<AudioHandler>().customAction("saveSession");
              await Get.find<HomeScreenController>().cachedHomeScreenData();
            }
            exit(0);
          }),
    ]);

    // set context menu
    await systemTray.setContextMenu(menu);

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        GetPlatform.isWindows
            ? windowManager.show()
            : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        GetPlatform.isWindows
            ? systemTray.popUpContextMenu()
            : windowManager.show();
      }
    });
    await windowManager.setPreventClose(true);
    listener = CloseWindowListener();
    windowManager.addListener(listener);
  }

  @override
  void onClose() {
    windowManager.removeListener(listener);
    super.onClose();
  }
}

class CloseWindowListener extends WindowListener {
  @override
  Future<void> onWindowClose() async {
    final settingsScrnController = Get.find<SettingsScreenController>();
    if (settingsScrnController.backgroundPlayEnabled.isTrue &&
        Get.find<PlayerController>().buttonState.value ==
            PlayButtonState.playing) {
      await windowManager.hide();
    } else {
      if (settingsScrnController.restorePlaybackSession.isTrue) {
        await Get.find<AudioHandler>().customAction("saveSession");
        await Get.find<HomeScreenController>().cachedHomeScreenData();
      }
      exit(0);
    }
  }
}
