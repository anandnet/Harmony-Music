import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';

import 'settings_screen_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsScreenController>();
    return Padding(
      padding: const EdgeInsets.only(top: 90.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Settings",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
              child: ListView(
            children: [
              ListTile(
                title: const Text("Theme mode"),
                subtitle: Obx(
                  () => Text(settingsController.themeModetype.value ==
                          ThemeType.dynamic
                      ? "dynamic"
                      : settingsController.themeModetype.value ==
                              ThemeType.system
                          ? "system default"
                          : settingsController.themeModetype.value ==
                                  ThemeType.dark
                              ? "dark"
                              : "light"),
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => const ThemeSelectorDialog(),
                ),
              ),
              ListTile(
                  title: const Text("Caching songs"),
                  subtitle: const Text("Caching songs while playing"),
                  trailing: Obx(
                    () => Switch(
                        value: settingsController.cacheSongs.value,
                        onChanged: settingsController.toggleCachingSongsValue),
                  )),
              ListTile(
                  title: const Text("Skip Silence"),
                  subtitle:
                      const Text("Silence will be skipped in music playback."),
                  trailing: Obx(
                    () => Switch(
                        value: settingsController.skipSilenceEnabled.value,
                        onChanged: settingsController.toggleSkipSilence),
                  )),
              ListTile(
                title: const Text("Streaming Quality"),
                subtitle: const Text("Quality of music stream"),
                trailing: Obx(
                  () => DropdownButton(
                    dropdownColor: Theme.of(context).cardColor,
                    underline: const SizedBox.shrink(),
                    value: settingsController.streamingQuality.value,
                    items: const [
                      DropdownMenuItem(
                          value: AudioQuality.Low, child: Text("Low")),
                      DropdownMenuItem(
                        value: AudioQuality.High,
                        child: Text("High"),
                      ),
                    ],
                    onChanged: settingsController.setStreamingQuality,
                  ),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}

class ThemeSelectorDialog extends StatelessWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsScreenController>();
    return Dialog(
      child: Container(
        height: 280,
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.only(top: 30, left: 5, right: 30, bottom: 10),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Theme Mode",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          radioWidget(
              label: "Dynamic",
              controller: settingsController,
              value: ThemeType.dynamic),
          radioWidget(
              label: "System default",
              controller: settingsController,
              value: ThemeType.system),
          radioWidget(
              label: "Dark",
              controller: settingsController,
              value: ThemeType.dark),
          radioWidget(
              label: "Light",
              controller: settingsController,
              value: ThemeType.light),
          Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Cancel"),
                ),
                onTap: () => Navigator.of(context).pop(),
              ))
        ]),
      ),
    );
  }

  Widget radioWidget(
      {required String label,
      required SettingsScreenController controller,
      required value}) {
    return Obx(() => ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          leading: Radio(
              value: value,
              groupValue: controller.themeModetype.value,
              onChanged: controller.onThemeChange),
          title: Text(label),
        ));
  }
}
