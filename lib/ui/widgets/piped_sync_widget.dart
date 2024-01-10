import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/utils/helper.dart';

import '../screens/Library/library_controller.dart';
import 'snackbar.dart';

class PipedSyncWidget extends StatelessWidget {
  const PipedSyncWidget({super.key, required this.padding});
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final librplstCntrller = Get.find<LibraryPlaylistsController>();
    return Padding(
      padding: padding,
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(librplstCntrller.controller),
        child: IconButton(
            splashRadius: 20,
            iconSize: 20,
            visualDensity: const VisualDensity(vertical: -4),
            icon: const Icon(
              Icons.sync,
            ), // <-- Icon
            onPressed: () async {
              try {
                //printINFO(librplstCntrller.controller.status);
                librplstCntrller.controller.forward();
                librplstCntrller.controller.repeat();
                await librplstCntrller.syncPipedPlaylist();
                librplstCntrller.controller.stop();
                librplstCntrller.controller.reset();
                ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
                    Get.context!, "pipedplstSyncAlert".tr,
                    size: SanckBarSize.MEDIUM));
              } catch (e) {
                ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
                    Get.context!, "errorOccuredAlert".tr,
                    size: SanckBarSize.BIG));
                printERROR(e);
              }
            }),
      ),
    );
  }
}
