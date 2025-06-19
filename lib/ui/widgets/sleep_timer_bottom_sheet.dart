import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/player/player_controller.dart';
import 'snackbar.dart';

class SleepTimerBottomSheet extends StatelessWidget {
  const SleepTimerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    return Padding(
      padding: EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.timer),
              title: Text("sleepTimer".tr),
            ),
            const Divider(),
            if (playerController.isSleepTimerActive.isTrue)
              SizedBox(
                height: 90,
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20)),
                  child: Align(
                    alignment: Alignment.center,
                    child: Obx(() {
                      final leftDurationInSec =
                          playerController.timerDurationLeft.value;
                      final hrs = (leftDurationInSec ~/ 3600)
                          .toString()
                          .padLeft(2, '0');
                      final min = ((leftDurationInSec % 3600) ~/ 60)
                          .toString()
                          .padLeft(2, '0');
                      final sec = ((leftDurationInSec % 3600) % 60)
                          .toString()
                          .padLeft(2, '0');

                      return Text(
                        "$hrs:$min:$sec",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: 35),
                      );
                    }),
                  ),
                ),
              ),
            if (playerController.isSleepTimerActive.isFalse)
              Column(
                children: getTimeListWidget(context),
              ),
            if (playerController.isSleepTimerActive.isTrue)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (playerController.isSleepEndOfSongActive.isFalse)
                      OutlinedButton(
                          onPressed: playerController.addFiveMinutes,
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).textTheme.titleMedium!.color!,
                            side: BorderSide(
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .color!,
                            ),
                          ),
                          child: Text("add5Minutes".tr)),
                    OutlinedButton(
                        onPressed: () {
                          Future.delayed(const Duration(milliseconds: 200),
                              playerController.cancelSleepTimer);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(snackbar(
                              context, "cancelTimerAlert".tr,
                              size: SanckBarSize.BIG));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).textTheme.titleMedium!.color!,
                          side: BorderSide(
                            color:
                                Theme.of(context).textTheme.titleMedium!.color!,
                          ),
                        ),
                        child: Text("cancelTimer".tr))
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> getTimeListWidget(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final List<Widget> widgets = [];
    widgets.addAll([5, 10, 15, 30, 45, 60]
        .map((dur) => ListTile(
              onTap: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 200), () {
                  playerController.startSleepTimer(dur);
                });
                ScaffoldMessenger.of(context).showSnackBar(snackbar(
                    context, "sleepTimeSetAlert".tr,
                    size: SanckBarSize.BIG));
              },
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  "$dur ${'minutes'.tr}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ))
        .toList());
    widgets.add(ListTile(
      onTap: () {
        Navigator.of(context).pop();
        playerController.sleepEndOfSong();
      },
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          "endOfThisSong".tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    ));
    return widgets;
  }
}
