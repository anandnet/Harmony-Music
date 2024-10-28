import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/res/tailwind_ext.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/Library/library_controller.dart';
import 'package:harmonymusic/ui/screens/Settings/components/custom_expansion_tile.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';
import 'package:harmonymusic/ui/widgets/backup_dialog.dart';
import 'package:harmonymusic/ui/widgets/common_dialog_widget.dart';
import 'package:harmonymusic/ui/widgets/cust_switch.dart';
import 'package:harmonymusic/ui/widgets/export_file_dialog.dart';
import 'package:harmonymusic/ui/widgets/link_piped.dart';
import 'package:harmonymusic/ui/widgets/restore_dialog.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:harmonymusic/utils/lang_mapping.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.isBottomNavActive = false});

  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsScreenController>();
    final topPadding = context.isLandscape ? 50.0 : 90.0;
    final isDesktop = GetPlatform.isDesktop;
    return Padding(
        padding: isBottomNavActive
            ? EdgeInsets.only(left: 20, top: topPadding, right: 15)
            : EdgeInsets.only(top: topPadding, left: 5, right: 5),
        child: column.children([
          Align(
            alignment: Alignment.centerLeft,
            child: 'settings'.tr.text.titleLarge.mk,
          ),
          Expanded(
              child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 200, top: 20),
            children: [
              Obx(
                () => settingsController.isNewVersionAvailable.value
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8, right: 10, bottom: 8),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            tileColor: Theme.of(context).colorScheme.secondary,
                            contentPadding: const EdgeInsets.only(left: 8, right: 10),
                            leading: const CircleAvatar(child: Icon(Icons.download_rounded)),
                            title: Text('newVersionAvailable'.tr),
                            visualDensity: const VisualDensity(horizontal: -2),
                            subtitle: Text(
                              'goToDownloadPage'.tr,
                              style:
                                  Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              CustomExpansionTile(
                title: 'personalisation'.tr,
                icon: Icons.palette,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: 'themeMode'.tr.text.mk,
                    subtitle: Obx(
                      () => (settingsController.themeModetype.value == ThemeType.dynamic
                              ? 'dynamic'.tr
                              : settingsController.themeModetype.value == ThemeType.system
                                  ? 'systemDefault'.tr
                                  : settingsController.themeModetype.value == ThemeType.dark
                                      ? 'dark'.tr
                                      : 'light'.tr)
                          .text
                          .bodyMedium
                          .mk,
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => const ThemeSelectorDialog(),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: 'language'.tr.text.mk,
                    subtitle: 'languageDes'.tr.text.bodyMedium.mk,
                    trailing: Obx(
                      () => DropdownButton(
                        menuMaxHeight: Get.height - 250,
                        dropdownColor: Theme.of(context).cardColor,
                        underline: const SizedBox.shrink(),
                        style: Theme.of(context).textTheme.titleSmall,
                        value: settingsController.currentAppLanguageCode.value,
                        items: langMap.entries
                            .map((lang) => DropdownMenuItem(
                                  value: lang.key,
                                  child: Text(lang.value),
                                ))
                            .whereType<DropdownMenuItem<String>>()
                            .toList(),
                        selectedItemBuilder: (context) => langMap.entries.map<Widget>((item) {
                          return Container(
                            alignment: Alignment.centerRight,
                            constraints: const BoxConstraints(minWidth: 50),
                            child: item.value.text.mk,
                          );
                        }).toList(),
                        onChanged: settingsController.setAppLanguage,
                      ),
                    ),
                  ),
                  if (!isDesktop)
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: 'playerUi'.tr.text.mk,
                      subtitle: 'playerUiDes'.tr.text.bodyMedium.mk,
                      trailing: Obx(
                        () => DropdownButton(
                          dropdownColor: Theme.of(context).cardColor,
                          underline: const SizedBox.shrink(),
                          value: settingsController.playerUi.value,
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: 'standard'.tr.text.mk,
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: 'gesture'.tr.text.mk,
                            ),
                          ],
                          onChanged: settingsController.setPlayerUi,
                        ),
                      ),
                    ),
                  if (!isDesktop)
                    ListTile(
                        contentPadding: const EdgeInsets.only(left: 5, right: 10),
                        title: 'enableBottomNav'.tr.text.mk,
                        subtitle: 'enableBottomNavDes'.tr.text.bodyMedium.mk,
                        trailing: Obx(
                          () => CustSwitch(
                              value: settingsController.isBottomNavBarEnabled.isTrue,
                              onChanged: settingsController.enableBottomNavBar),
                        )),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: 'disableTransitionAnimation'.tr.text.mk,
                    subtitle: 'disableTransitionAnimationDes'.tr.text.bodyMedium.mk,
                    trailing: Obx(
                      () => CustSwitch(
                          value: settingsController.isTransitionAnimationDisabled.isTrue,
                          onChanged: settingsController.disableTransitionAnimation),
                    ),
                  ),
                  ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: 'enableSlidableAction'.tr.text.mk,
                      subtitle: 'enableSlidableActionDes'.tr.text.bodyMedium.mk,
                      trailing: Obx(
                        () => CustSwitch(
                            value: settingsController.slidableActionEnabled.isTrue,
                            onChanged: settingsController.toggleSlidableAction),
                      )),
                ],
              ),
              CustomExpansionTile(
                title: 'content'.tr,
                icon: Icons.music_video,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: 'setDiscoverContent'.tr.text.mk,
                    subtitle: Obx(
                      () => (settingsController.discoverContentType.value == 'QP'
                              ? 'quickpicks'.tr
                              : settingsController.discoverContentType.value == 'TMV'
                                  ? 'topmusicvideos'.tr
                                  : settingsController.discoverContentType.value == 'TR'
                                      ? 'trending'.tr
                                      : 'basedOnLast'.tr)
                          .text
                          .bodyMedium
                          .mk,
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => const DiscoverContentSelectorDialog(),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: 'homeContentCount'.tr.text.mk,
                    subtitle: 'homeContentCountDes'.tr.text.mk,
                    trailing: Obx(
                      () => DropdownButton(
                        dropdownColor: Theme.of(context).cardColor,
                        underline: const SizedBox.shrink(),
                        value: settingsController.noOfHomeScreenContent.value,
                        items: [3, 5, 7, 9, 11]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: '$e'.text.mk,
                                ))
                            .toList(),
                        onChanged: settingsController.setContentNumber,
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: 'cacheHomeScreenData'.tr.text.mk,
                    subtitle: 'cacheHomeScreenDataDes'.tr.text.bodyMedium.mk,
                    trailing: Obx(
                      () => CustSwitch(
                          value: settingsController.cacheHomeScreenData.value,
                          onChanged: settingsController.toggleCacheHomeScreenData),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: 'Piped'.tr.text.mk,
                    subtitle: 'linkPipedDes'.tr.text.bodyMedium.mk,
                    trailing: TextButton(
                        child: Obx(
                          () => (settingsController.isLinkedWithPiped.value ? 'unLink'.tr : 'link'.tr)
                              .text
                              .titleMedium
                              .f15
                              .mk,
                        ),
                        onPressed: () {
                          if (settingsController.isLinkedWithPiped.isFalse) {
                            showDialog(
                              context: context,
                              builder: (context) => const LinkPiped(),
                            ).whenComplete(() => Get.delete<PipedLinkedController>());
                          } else {
                            settingsController.unlinkPiped();
                          }
                        }),
                  ),
                  Obx(
                    () => (settingsController.isLinkedWithPiped.isTrue)
                        ? ListTile(
                            contentPadding: const EdgeInsets.only(left: 5, right: 10),
                            title: 'resetblacklistedplaylist'.tr.text.mk,
                            subtitle: 'resetblacklistedplaylistDes'.tr.text.bodyMedium.mk,
                            trailing: TextButton(
                                child: 'reset'.tr.text.titleMedium.f15.mk,
                                onPressed: () async {
                                  await Get.find<LibraryPlaylistsController>().resetBlacklistedPlaylist();
                                  ScaffoldMessenger.of(Get.context!)
                                      .showSnackBar(snackbar(Get.context!, 'blacklistPlstResetAlert'.tr));
                                }),
                          )
                        : const SizedBox.shrink(),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: Text('clearImgCache'.tr),
                    subtitle: Text(
                      'clearImgCacheDes'.tr,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    isThreeLine: true,
                    onTap: () {
                      settingsController.clearImagesCache().then((value) => ScaffoldMessenger.of(Get.context!)
                          .showSnackBar(snackbar(Get.context!, 'clearImgCacheAlert'.tr, size: SanckBarSize.BIG)));
                    },
                  ),
                ],
              ),
              CustomExpansionTile(
                title: 'music&Playback'.tr,
                icon: Icons.music_note,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: Text('streamingQuality'.tr),
                    subtitle: Text('streamingQualityDes'.tr, style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Obx(
                      () => DropdownButton(
                        dropdownColor: Theme.of(context).cardColor,
                        underline: const SizedBox.shrink(),
                        value: settingsController.streamingQuality.value,
                        items: [
                          DropdownMenuItem(value: AudioQuality.Low, child: Text('low'.tr)),
                          DropdownMenuItem(
                            value: AudioQuality.High,
                            child: Text('high'.tr),
                          ),
                        ],
                        onChanged: settingsController.setStreamingQuality,
                      ),
                    ),
                    onLongPress: settingsController.showDownLoc,
                  ),
                  if (GetPlatform.isAndroid)
                    ListTile(
                        contentPadding: const EdgeInsets.only(left: 5, right: 10),
                        title: Text('loudnessNormalization'.tr),
                        subtitle: Text('loudnessNormalizationDes'.tr, style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Obx(
                          () => CustSwitch(
                              value: settingsController.loudnessNormalizationEnabled.value,
                              onChanged: settingsController.toggleLoudnessNormalization),
                        )),
                  if (!isDesktop)
                    ListTile(
                        contentPadding: const EdgeInsets.only(left: 5, right: 10),
                        title: Text('cacheSongs'.tr),
                        subtitle: Text('cacheSongsDes'.tr, style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Obx(
                          () => CustSwitch(
                              value: settingsController.cacheSongs.value,
                              onChanged: settingsController.toggleCachingSongsValue),
                        )),
                  if (!isDesktop)
                    ListTile(
                        contentPadding: const EdgeInsets.only(left: 5, right: 10),
                        title: Text('skipSilence'.tr),
                        subtitle: Text('skipSilenceDes'.tr, style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Obx(
                          () => CustSwitch(
                              value: settingsController.skipSilenceEnabled.value,
                              onChanged: settingsController.toggleSkipSilence),
                        )),
                  if (isDesktop)
                    ListTile(
                        contentPadding: const EdgeInsets.only(left: 5, right: 10),
                        title: Text('backgroundPlay'.tr),
                        subtitle: Text('backgroundPlayDes'.tr, style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Obx(
                          () => CustSwitch(
                              value: settingsController.backgroundPlayEnabled.value,
                              onChanged: settingsController.toggleBackgroundPlay),
                        )),
                  ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text('restoreLastPlaybackSession'.tr),
                      subtitle: Text('restoreLastPlaybackSessionDes'.tr, style: Theme.of(context).textTheme.bodyMedium),
                      trailing: Obx(
                        () => CustSwitch(
                            value: settingsController.restorePlaybackSession.value,
                            onChanged: settingsController.toggleRestorePlaybackSession),
                      )),
                  if (!isDesktop)
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text('equalizer'.tr),
                      subtitle: Text('equalizerDes'.tr, style: Theme.of(context).textTheme.bodyMedium),
                      onTap: () async {
                        try {
                          await Get.find<PlayerController>().openEqualizer();
                        } catch (e) {
                          printERROR(e);
                        }
                      },
                    ),
                  if (!isDesktop)
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text('stopMusicOnTaskClear'.tr),
                      subtitle: Text('stopMusicOnTaskClearDes'.tr, style: Theme.of(context).textTheme.bodyMedium),
                      trailing: Obx(
                        () => CustSwitch(
                            value: settingsController.stopPlyabackOnSwipeAway.value,
                            onChanged: settingsController.toggleStopPlyabackOnSwipeAway),
                      ),
                    ),
                  GetPlatform.isAndroid
                      ? Obx(
                          () => ListTile(
                            contentPadding: const EdgeInsets.only(left: 5, right: 10),
                            title: Text('ignoreBatOpt'.tr),
                            onTap: settingsController.isIgnoringBatteryOptimizations.isFalse
                                ? settingsController.enableIgnoringBatteryOptimizations
                                : null,
                            subtitle: Obx(() => RichText(
                                  text: TextSpan(
                                    text:
                                        "${"status".tr}: ${settingsController.isIgnoringBatteryOptimizations.isTrue ? "enabled".tr : "disabled".tr}\n",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'ignoreBatOptDes'.tr, style: Theme.of(context).textTheme.bodyMedium),
                                    ],
                                  ),
                                )),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              CustomExpansionTile(
                title: 'download'.tr,
                icon: Icons.download_rounded,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: Text('downloadingFormat'.tr),
                    subtitle: Text('downloadingFormatDes'.tr, style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Obx(
                      () => DropdownButton(
                        dropdownColor: Theme.of(context).cardColor,
                        underline: const SizedBox.shrink(),
                        value: settingsController.downloadingFormat.value,
                        items: const [
                          DropdownMenuItem(value: 'opus', child: Text('Opus/Ogg')),
                          DropdownMenuItem(
                            value: 'm4a',
                            child: Text('M4a'),
                          ),
                        ],
                        onChanged: settingsController.changeDownloadingFormat,
                      ),
                    ),
                  ),
                  Obx(() => settingsController.hideDloc.isFalse || isDesktop
                      ? ListTile(
                          trailing: TextButton(
                            onPressed: settingsController.resetDownloadLocation,
                            child: Text(
                              'reset'.tr,
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 15),
                            ),
                          ),
                          contentPadding: const EdgeInsets.only(left: 5, right: 10),
                          title: Text('downloadLocation'.tr),
                          subtitle: Obx(() => Text(
                              settingsController.isCurrentPathsupportDownDir
                                  ? 'In App storage directory'
                                  : settingsController.downloadLocationPath.value,
                              style: Theme.of(context).textTheme.bodyMedium)),
                          onTap: () async {
                            settingsController.setDownloadLocation();
                          },
                        )
                      : const SizedBox.shrink()),
                  if (GetPlatform.isAndroid)
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text('exportDowloadedFiles'.tr),
                      subtitle: Text(
                        'exportDowloadedFilesDes'.tr,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      isThreeLine: true,
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => const ExportFileDialog(),
                      ).whenComplete(() => Get.delete<ExportFileDialogController>()),
                    ),
                  if (GetPlatform.isAndroid)
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text('exportedFileLocation'.tr),
                      subtitle: Obx(() => Text(settingsController.exportLocationPath.value,
                          style: Theme.of(context).textTheme.bodyMedium)),
                      onTap: () async {
                        settingsController.setExportedLocation();
                      },
                    ),
                ],
              ),
              CustomExpansionTile(title: "${"backup".tr} & ${"restore".tr}", icon: Icons.restore_rounded, children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 5, right: 10),
                  title: Text('backupAppData'.tr),
                  subtitle: Text(
                    'backupSettingsAndPlaylistsDes'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  isThreeLine: true,
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => const BackupDialog(),
                  ).whenComplete(() => Get.delete<BackupDialogController>()),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 5, right: 10),
                  title: Text('restoreAppData'.tr),
                  subtitle: Text(
                    'restoreSettingsAndPlaylistsDes'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  isThreeLine: true,
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => const RestoreDialog(),
                  ).whenComplete(() => Get.delete<RestoreDialogController>()),
                ),
              ]),
              CustomExpansionTile(
                icon: Icons.info,
                title: 'appInfo'.tr,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: Text('github'.tr),
                    subtitle: Text(
                      "${"githubDes".tr}${((Get.find<PlayerController>().playerPanelMinHeight.value) == 0 || !isBottomNavActive) ? "" : "\n\n${settingsController.currentVersion} ${"by".tr} anandnet"}",
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
                  ),
                  const Divider(),
                  SizedBox(
                    child: Column(
                      children: [
                        Text(
                          'Harmony Music',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(settingsController.currentVersion, style: Theme.of(context).textTheme.titleMedium)
                      ],
                    ),
                  ),
                ],
              )
            ],
          )),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              "${settingsController.currentVersion} ${"by".tr} anandnet",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ]));
  }
}

class ThemeSelectorDialog extends StatelessWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsScreenController>();
    return CommonDialog(
      child: Container(
        height: 300,
        padding: const EdgeInsets.only(top: 30, left: 5, right: 30, bottom: 10),
        child: column.children([
          padding.pl40.pb10.child(
            Align(
              alignment: Alignment.centerLeft,
              child: 'themeMode'.tr.text.titleLarge.mk,
            ),
          ),
          radioWidget(
            label: 'dynamic'.tr,
            controller: settingsController,
            value: ThemeType.dynamic,
          ),
          radioWidget(label: 'systemDefault'.tr, controller: settingsController, value: ThemeType.system),
          radioWidget(label: 'dark'.tr, controller: settingsController, value: ThemeType.dark),
          radioWidget(label: 'light'.tr, controller: settingsController, value: ThemeType.light),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: padding.p16.child(
                'cancel'.tr.text.mk,
              ),
            ),
          )
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
    return CommonDialog(
      child: Container(
        height: 300,
        padding: const EdgeInsets.only(top: 30, left: 5, right: 30, bottom: 10),
        child: column.children([
          padding.pl40.pb10.child(
            Align(
              alignment: Alignment.centerLeft,
              child: 'setDiscoverContent'.tr.text.titleLarge.mk,
            ),
          ),
          sizedBox.h350.child(
            SingleChildScrollView(
              child: column.children([
                radioWidget(label: 'quickpicks'.tr, controller: settingsController, value: 'QP'),
                radioWidget(label: 'topmusicvideos'.tr, controller: settingsController, value: 'TMV'),
                radioWidget(label: 'trending'.tr, controller: settingsController, value: 'TR'),
                radioWidget(label: 'basedOnLast'.tr, controller: settingsController, value: 'BOLI'),
              ]),
            ),
          ),
          spacer,
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              child: padding.p12.child(
                'cancel'.tr.text.mk,
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ]),
      ),
    );
  }
}

Widget radioWidget({required String label, required SettingsScreenController controller, required value}) {
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
            groupValue:
                value.runtimeType == ThemeType ? controller.themeModetype.value : controller.discoverContentType.value,
            onChanged: value.runtimeType == ThemeType ? controller.onThemeChange : controller.onContentChange),
        title: Text(label),
      ));
}
