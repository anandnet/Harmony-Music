import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '/ui/utils/home_library_controller.dart';
import '../widgets/snackbar.dart';
import '/ui/widgets/link_piped.dart';
import '/services/music_service.dart';
import '/ui/player/player_controller.dart';
import '/ui/utils/theme_controller.dart';
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
              Obx(
                () => settingsController.isNewVersionAvailable.value
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 10),
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            onTap: () {
                              launchUrl(
                                Uri.parse(
                                  'https://github.com/anandnet/Harmony-Music/releases/latest',
                                ),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            tileColor: Theme.of(context).colorScheme.secondary,
                            contentPadding:
                                const EdgeInsets.only(left: 8, right: 10),
                            leading: const CircleAvatar(
                                child: Icon(Icons.download_rounded)),
                            title: const Text("New Version available!"),
                            visualDensity: const VisualDensity(horizontal: -2),
                            subtitle: Text(
                              "Click here to go to download page",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
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
                title: const Text("Set Discover content"),
                subtitle: Obx(() => Text(
                    settingsController.discoverContentType.value == "QP"
                        ? "Quick Picks"
                        : settingsController.discoverContentType.value == "TMV"
                            ? "Top Music Videos"
                            : settingsController.discoverContentType.value ==
                                    "TR"
                                ? "Trending"
                                : "Based on last interaction",
                    style: Theme.of(context).textTheme.bodyMedium)),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => const DiscoverContentSelectorDialog(),
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
              ListTile(
                contentPadding:
                    const EdgeInsets.only(left: 5, right: 10, top: 0),
                title: const Text("Equalizer"),
                subtitle: Text("Open system euqalizer",
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () async {
                  await Get.find<PlayerController>().openEqualizer();
                },
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.only(left: 5, right: 10, top: 0),
                title: const Text("Piped"),
                subtitle: Text("Link with piped for playlists",
                    style: Theme.of(context).textTheme.bodyMedium),
                trailing: TextButton(
                    child: Obx(() => Text(
                          settingsController.isLinkedWithPiped.value
                              ? "Unlink"
                              : "link",
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(fontSize: 15),
                        )),
                    onPressed: () {
                      if (settingsController.isLinkedWithPiped.isFalse) {
                        showDialog(
                          context: context,
                          builder: (context) => const LinkPiped(),
                        ).whenComplete(
                            () => Get.delete<PipedLinkedController>());
                      } else {
                        settingsController.unlinkPiped();
                      }
                    }),
              ),
              Obx(() => (settingsController.isLinkedWithPiped.isTrue)
                  ? ListTile(
                      contentPadding:
                          const EdgeInsets.only(left: 5, right: 10, top: 0),
                      title: const Text("Reset blacklisted playlists"),
                      subtitle: Text(
                          "Reset all the piped blacklisted playlists",
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: TextButton(
                          child: Text(
                            "Reset",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize:15 ),
                          ),
                          onPressed: () async {
                            await Get.find<LibraryPlaylistsController>()
                                .resetBlacklistedPlaylist();
                            ScaffoldMessenger.of(Get.context!).showSnackBar(
                                snackbar(Get.context!, "Reset successfully!",
                                    size: SanckBarSize.MEDIUM));
                          }),
                    )
                  : const SizedBox.shrink()),
              ListTile(
                  contentPadding: const EdgeInsets.only(left: 5, right: 10),
                  title: const Text("Stop music on task clear"),
                  subtitle: Text("Music playback will stop when App being swiped away from the task manager",
                      style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Obx(
                    () => Switch(
                        value: settingsController.stopPlyabackOnSwipeAway.value,
                        onChanged: settingsController.toggleStopPlyabackOnSwipeAway),
                  )),
              GetPlatform.isAndroid
                  ? Obx(
                      () => ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 5, right: 10),
                        title: const Text("Ignore battery optimization"),
                        onTap: settingsController
                                .isIgnoringBatteryOptimizations.isFalse
                            ? settingsController
                                .enableIgnoringBatteryOptimizations
                            : null,
                        subtitle: Obx(() => RichText(
                              text: TextSpan(
                                text:
                                    "Status: ${settingsController.isIgnoringBatteryOptimizations.isTrue ? "Enabled" : "Disabled"}\n",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          "If you are facing notification issues or playback stopped by system optimization, please enable this option",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ],
                              ),
                            )),
                      ),
                    )
                  : const SizedBox.shrink(),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 5, right: 10),
                title: const Text("Github"),
                subtitle: Text(
                  "View Github source code \nif you like this project, don't forget to give a ⭐${((Get.find<PlayerController>().playerPanelMinHeight.value) == 0) ? "" : "\n\n${settingsController.currentVersion} by anandnet"}",
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
              "${settingsController.currentVersion} by anandnet",
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
            value: ThemeType.dynamic,
          ),
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
}

class DiscoverContentSelectorDialog extends StatelessWidget {
  const DiscoverContentSelectorDialog({super.key});

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
                "Set Discover content",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          radioWidget(
              label: "Quick Picks",
              controller: settingsController,
              value: "QP"),
          radioWidget(
              label: "Top Music Videos",
              controller: settingsController,
              value: "TMV"),
          radioWidget(
              label: "Trending", controller: settingsController, value: "TR"),
          radioWidget(
              label: "Based on last interaction",
              controller: settingsController,
              value: "BOLI"),
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
}

Widget radioWidget(
    {required String label,
    required SettingsScreenController controller,
    required value}) {
  return Obx(() => ListTile(
        visualDensity: const VisualDensity(vertical: -4),
        onTap: () {
          if (value.runtimeType == ThemeType) {
            controller.onThemeChange(value);
          } else {
            controller.onContentChange(value);
            Navigator.of(Get.context!).pop();
          }
        },
        leading: Radio(
            value: value,
            groupValue: value.runtimeType == ThemeType
                ? controller.themeModetype.value
                : controller.discoverContentType.value,
            onChanged: value.runtimeType == ThemeType
                ? controller.onThemeChange
                : controller.onContentChange),
        title: Text(label),
      ));
}
