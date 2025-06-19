import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class DesktopSystemTray extends GetxService with TrayListener {
  late WindowListener listener;

  @override
  void onInit() {
    trayManager.addListener(this);
    Future.delayed(const Duration(seconds: 2), () => initSystemTray());
    super.onInit();
  }

  Future<void> initSystemTray() async {
    String path = GetPlatform.isWindows
        ? 'assets/icons/icon.ico'
        : 'assets/icons/icon.png';

    await windowManager.ensureInitialized();
    final playerController = Get.find<PlayerController>();

    await trayManager.setIcon(path);

    // create context menu
    final Menu menu = Menu(items: [
      MenuItem(
        label: 'Show/Hide',
        onClick: (menuItem) async => await windowManager.isVisible()
            ? await windowManager.hide()
            : await windowManager.show(),
      ),
      MenuItem.separator(),
      MenuItem(
        label: 'Prev',
        onClick: (menuItem) {
          if (playerController.currentQueue.isNotEmpty) {
            playerController.prev();
          }
        },
      ),
      MenuItem(
        label: 'Play/Pause',
        onClick: (menuItem) {
          if (playerController.currentQueue.isNotEmpty) {
            playerController.playPause();
          }
        },
      ),
      MenuItem(
        label: 'Next',
        onClick: (menuItem) {
          if (playerController.currentQueue.isNotEmpty) {
            playerController.next();
          }
        },
      ),
      MenuItem.separator(),
      MenuItem(
        label: 'Quit',
        onClick: (menuItem) async {
          await Get.find<AudioHandler>().customAction("saveSession");
          exit(0);
        },
      ),
    ]);

    // set context menu
    await trayManager.setContextMenu(menu);

    await windowManager.setPreventClose(true);
    listener = CloseWindowListener();
    windowManager.addListener(listener);
  }

  @override
  void onClose() {
    trayManager.removeListener(this);
    windowManager.removeListener(listener);
    super.onClose();
  }

  @override
  void onTrayIconMouseDown() {
    if (GetPlatform.isWindows) {
      windowManager.show();
    } else {
      trayManager.popUpContextMenu();
    }

    super.onTrayIconMouseDown();
  }

  @override
  void onTrayIconRightMouseDown() {
    if (GetPlatform.isWindows) {
      trayManager.popUpContextMenu();
    } else {
      windowManager.show();
    }

    super.onTrayIconRightMouseDown();
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
      await Get.find<AudioHandler>().customAction("saveSession");
      exit(0);
    }
  }
}
