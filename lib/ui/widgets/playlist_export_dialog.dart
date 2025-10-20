import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '/ui/screens/Playlist/playlist_screen_controller.dart';
import 'common_dialog_widget.dart';
import 'snackbar.dart';

class PlaylistExportDialog extends StatelessWidget {
  const PlaylistExportDialog({
    super.key,
    required this.controller,
  });

  final PlaylistScreenController controller;

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: Text(
                "exportPlaylist".tr,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            // Button 1: Export to JSON
            _ExportButton(
              icon: Icons.save,
              title: "exportPlaylistJson".tr,
              subtitle: "exportPlaylistJsonSubtitle".tr,
              onTap: () {
                Navigator.of(context).pop();
                controller.exportPlaylistToJson(context);
              },
            ),
            const SizedBox(height: 12),
            // Button 2: Export to CSV
            _ExportButton(
              icon: Icons.table_chart,
              title: "exportPlaylistCsv".tr,
              subtitle: "exportPlaylistCsvSubtitle".tr,
              onTap: () {
                Navigator.of(context).pop();
                controller.exportPlaylistToCsv(context);
              },
            ),
            const SizedBox(height: 12),
            // Button 3: Export to YouTube Music (split button)
            _SplitExportButton(
              icon: Icons.open_in_new,
              title: "exportToYouTubeMusic".tr,
              subtitle: "exportToYouTubeMusicSubtitle".tr,
              onMainTap: () {
                Navigator.of(context).pop();
                _openInYouTubeMusic(context);
              },
              onCopyTap: () {
                Navigator.of(context).pop();
                _copyYouTubeMusicLink(context);
              },
            ),
            const SizedBox(height: 20),
            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "close".tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInYouTubeMusic(BuildContext context) {
    final videoIds = controller.songList.map((song) => song.id).join(',');
    final url = 'https://www.youtube.com/watch_videos?video_ids=$videoIds';
    
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void _copyYouTubeMusicLink(BuildContext context) {
    final videoIds = controller.songList.map((song) => song.id).join(',');
    final url = 'https://www.youtube.com/watch_videos?video_ids=$videoIds';
    
    Clipboard.setData(ClipboardData(text: url)).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          snackbar(
            context,
            "linkCopied".tr,
            size: SanckBarSize.MEDIUM,
          ),
        );
      }
    });
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).textTheme.titleMedium!.color,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplitExportButton extends StatelessWidget {
  const _SplitExportButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onMainTap,
    required this.onCopyTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onMainTap;
  final VoidCallback onCopyTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Main button part (80%)
              Expanded(
                flex: 8,
                child: InkWell(
                  onTap: onMainTap,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: Theme.of(context).textTheme.titleMedium!.color,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Divider
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
              // Copy button part (20%)
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: onCopyTap,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.copy,
                      color: Theme.of(context).textTheme.titleMedium!.color,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
