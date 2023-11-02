import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/utils/lang_mapping.dart';
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
              "settings".tr,
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
                            title: Text("newVersionAvailable".tr),
                            visualDensity: const VisualDensity(horizontal: -2),
                            subtitle: Text(
                              "goToDownloadPage".tr,
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
                title: Text("themeMode".tr),
                subtitle: Obx(
                  () => Text(
                      settingsController.themeModetype.value ==
                              ThemeType.dynamic
                          ? "dynamic".tr
                          : settingsController.themeModetype.value ==
                                  ThemeType.system
                              ? "systemDefault".tr
                              : settingsController.themeModetype.value ==
                                      ThemeType.dark
                                  ? "dark".tr
                                  : "light".tr,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => const ThemeSelectorDialog(),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 5, right: 10),
                title: Text("language".tr),
                subtitle: Text("languageDes".tr,
                    style: Theme.of(context).textTheme.bodyMedium),
                trailing: Obx(
                  () => DropdownButton(
                    dropdownColor: Theme.of(context).cardColor,
                    underline: const SizedBox.shrink(),
                    style: Theme.of(context).textTheme.titleSmall,
                    value: settingsController.currentAppLanguageCode.value,
                    items: langMap.entries
                        .map((lang) =>
                            DropdownMenuItem(value: lang.key, child: Text(lang.value)))
                        .whereType<DropdownMenuItem<String>>()
                        .toList(),
                    selectedItemBuilder: (context) => langMap.entries
                        .map<Widget>((item) {
                      return Container(
                        alignment: Alignment.centerRight,
                        constraints: const BoxConstraints(minWidth: 50),
                        child: Text(
                          item.value,
                        ),
                      );
                    }).toList(),
                    onChanged: settingsController.setAppLanguage,
                  ),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 5, right: 10),
                title: Text("setDiscoverContent".tr),
                subtitle: Obx(() => Text(
                    settingsController.discoverContentType.value == "QP"
                        ? "quickpicks".tr
                        : settingsController.discoverContentType.value == "TMV"
                            ? "topmusicvideos".tr
                            : settingsController.discoverContentType.value ==
                                    "TR"
                                ? "trending".tr
                                : "basedOnLast".tr,
                    style: Theme.of(context).textTheme.bodyMedium)),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => const DiscoverContentSelectorDialog(),
                ),
              ),
              ListTile(
                  contentPadding: const EdgeInsets.only(left: 5, right: 10),
                  title: Text("cacheSongs".tr),
                  subtitle: Text("cacheSongsDes".tr,
                      style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Obx(
                    () => Switch(
                        value: settingsController.cacheSongs.value,
                        onChanged: settingsController.toggleCachingSongsValue),
                  )),
              ListTile(
                  contentPadding: const EdgeInsets.only(left: 5, right: 10),
                  title: Text("skipSilence".tr),
                  subtitle: Text("skipSilenceDes".tr,
                      style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Obx(
                    () => Switch(
                        value: settingsController.skipSilenceEnabled.value,
                        onChanged: settingsController.toggleSkipSilence),
                  )),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 5, right: 10),
                title: Text("streamingQuality".tr),
                subtitle: Text("streamingQualityDes".tr,
                    style: Theme.of(context).textTheme.bodyMedium),
                trailing: Obx(
                  () => DropdownButton(
                    dropdownColor: Theme.of(context).cardColor,
                    underline: const SizedBox.shrink(),
                    value: settingsController.streamingQuality.value,
                    items: [
                      DropdownMenuItem(
                          value: AudioQuality.Low, child: Text("low".tr)),
                      DropdownMenuItem(
                        value: AudioQuality.High,
                        child: Text("high".tr),
                      ),
                    ],
                    onChanged: settingsController.setStreamingQuality,
                  ),
                ),
              ),
               ListTile(
                contentPadding:
                    const EdgeInsets.only(left: 5, right: 10, top: 0),
                title: Text("downloadLocation".tr),
                subtitle: Obx(() => Text(settingsController.downloadLocationPath.value,
                    style: Theme.of(context).textTheme.bodyMedium)),
                onTap: () async {
                  settingsController.setDownloadLocation();
                },
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.only(left: 5, right: 10, top: 0),
                title: Text("equalizer".tr),
                subtitle: Text("equalizerDes".tr,
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () async {
                  await Get.find<PlayerController>().openEqualizer();
                },
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.only(left: 5, right: 10, top: 0),
                title: Text("Piped".tr),
                subtitle: Text("linkPipedDes".tr,
                    style: Theme.of(context).textTheme.bodyMedium),
                trailing: TextButton(
                    child: Obx(() => Text(
                          settingsController.isLinkedWithPiped.value
                              ? "unLink".tr
                              : "link".tr,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
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
                      title: Text("resetblacklistedplaylist".tr),
                      subtitle: Text("resetblacklistedplaylistDes".tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: TextButton(
                          child: Text(
                            "reset".tr,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 15),
                          ),
                          onPressed: () async {
                            await Get.find<LibraryPlaylistsController>()
                                .resetBlacklistedPlaylist();
                            ScaffoldMessenger.of(Get.context!).showSnackBar(
                                snackbar(
                                    Get.context!, "blacklistPlstResetAlert".tr,
                                    size: SanckBarSize.MEDIUM));
                          }),
                    )
                  : const SizedBox.shrink()),
              ListTile(
                  contentPadding: const EdgeInsets.only(left: 5, right: 10),
                  title: Text("stopMusicOnTaskClear".tr),
                  subtitle: Text("stopMusicOnTaskClearDes".tr,
                      style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Obx(
                    () => Switch(
                        value: settingsController.stopPlyabackOnSwipeAway.value,
                        onChanged:
                            settingsController.toggleStopPlyabackOnSwipeAway),
                  )),
              GetPlatform.isAndroid
                  ? Obx(
                      () => ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 5, right: 10),
                        title: Text("ignoreBatOpt".tr),
                        onTap: settingsController
                                .isIgnoringBatteryOptimizations.isFalse
                            ? settingsController
                                .enableIgnoringBatteryOptimizations
                            : null,
                        subtitle: Obx(() => RichText(
                              text: TextSpan(
                                text:
                                    "${"status".tr}: ${settingsController.isIgnoringBatteryOptimizations.isTrue ? "enabled".tr : "disabled".tr}\n",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: "ignoreBatOptDes".tr,
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
                title: Text("github".tr),
                subtitle: Text(
                  "${"githubDes".tr}${((Get.find<PlayerController>().playerPanelMinHeight.value) == 0) ? "" : "\n\n${settingsController.currentVersion} ${"by".tr} anandnet"}",
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
              "${settingsController.currentVersion} ${"by".tr} anandnet",
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
                "themeMode".tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          radioWidget(
            label: "dynamic".tr,
            controller: settingsController,
            value: ThemeType.dynamic,
          ),
          radioWidget(
              label: "systemDefault".tr,
              controller: settingsController,
              value: ThemeType.system),
          radioWidget(
              label: "dark".tr,
              controller: settingsController,
              value: ThemeType.dark),
          radioWidget(
              label: "light".tr,
              controller: settingsController,
              value: ThemeType.light),
          Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("cancel".tr),
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
                "setDiscoverContent".tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          radioWidget(
              label: "quickpicks".tr,
              controller: settingsController,
              value: "QP"),
          radioWidget(
              label: "topmusicvideos".tr,
              controller: settingsController,
              value: "TMV"),
          radioWidget(
              label: "trending".tr,
              controller: settingsController,
              value: "TR"),
          radioWidget(
              label: "basedOnLast".tr,
              controller: settingsController,
              value: "BOLI"),
          Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("cancel".tr),
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
