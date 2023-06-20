import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import 'settings_screen_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsScreenController>();
    return Padding(
      padding: const EdgeInsets.only(top: 90.0, left: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 90),
            children: [
              ListTile(
                contentPadding: const EdgeInsets.only(left: 5, right: 10),
                title: const Text("Theme mode"),
                subtitle: Obx(
                  () => Text(
                      settingsController.themeModetype.value ==
                              ThemeType.dynamic
                          ? "dynamic"
                          : settingsController.themeModetype.value ==
                                  ThemeType.system
                              ? "system default"
                              : settingsController.themeModetype.value ==
                                      ThemeType.dark
                                  ? "dark"
                                  : "light",
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => const ThemeSelectorDialog(),
                ),
              ),
              ListTile(
                  contentPadding: const EdgeInsets.only(left: 5, right: 10),
                  title: const Text("Cache songs"),
                  subtitle: Text(
                      "Caching songs while playing for future/offline playback, it will take additional space on your device",
                      style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Obx(
                    () => Switch(
                        value: settingsController.cacheSongs.value,
                        onChanged: settingsController.toggleCachingSongsValue),
                  )),
              ListTile(
                  contentPadding: const EdgeInsets.only(left: 5, right: 10),
                  title: const Text("Skip Silence"),
                  subtitle: Text("Silence will be skipped in music playback.",
                      style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Obx(
                    () => Switch(
                        value: settingsController.skipSilenceEnabled.value,
                        onChanged: settingsController.toggleSkipSilence),
                  )),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 5, right: 10),
                title: const Text("Streaming Quality"),
                subtitle: Text("Quality of music stream",
                    style: Theme.of(context).textTheme.bodyMedium),
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
              ),
              GetPlatform.isAndroid? Obx(
                () => ListTile(
                  contentPadding: const EdgeInsets.only(left: 5, right: 10),
                  title: const Text("Ignore battery optimization"),
                  onTap: settingsController
                          .isIgnoringBatteryOptimizations.isFalse
                      ? settingsController.enableIgnoringBatteryOptimizations
                      : null,
                  subtitle: Obx(() => RichText(
                        text: TextSpan(
                          text:
                              "Status: ${settingsController.isIgnoringBatteryOptimizations.isTrue ? "Enabled" : "Disblaled"}\n",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                          children: <TextSpan>[
                            TextSpan(
                                text:
                                    "If you are facing notification issues or playback stopped by system optimization, please enable this option",
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      )),
                ),
              ):const SizedBox.shrink(),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 5, right: 10),
                title: const Text("Github"),
                subtitle: Text(
                  "View Github source code \nif you like this project, don't forget to give a ⭐${((Get.find<PlayerController>().playerPanelMinHeight.value) == 0) ? "" : "\n\nV 1.1.0 by anandnet"}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                isThreeLine: true,
                onTap: () {
                  launchUrl(
                    Uri.parse(
                      'https://github.com/anandnet/Harmony-Music',
                    ),
                    mode: LaunchMode.externalApplication,
                  );
                },
              )
            ],
          )),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              "V 1.1.0 by anandnet",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: 280,
        //color: Theme.of(context).cardColor,
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
          onTap: () {
            controller.onThemeChange(value);
          },
          leading: Radio(
              value: value,
              groupValue: controller.themeModetype.value,
              onChanged: controller.onThemeChange),
          title: Text(label),
        ));
  }
}
