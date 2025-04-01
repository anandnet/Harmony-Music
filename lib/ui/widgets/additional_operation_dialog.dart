import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/widgets/common_dialog_widget.dart';
import 'package:harmonymusic/ui/widgets/sort_widget.dart';

import 'custom_button.dart';
import 'modification_list.dart';

class AdditionalOperationDialog extends StatelessWidget {
  const AdditionalOperationDialog(
      {super.key,
      required this.operationMode,
      required this.screenController,
      required this.controller});
  final OperationMode operationMode;
  final dynamic screenController;
  final SortWidgetController controller;

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      maxWidth: 600,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 0),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Text(
                operationMode == OperationMode.delete ||
                        operationMode == OperationMode.addToPlaylist
                    ? "selectSongs".tr
                    : "reArrangeSongs".tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (operationMode == OperationMode.delete ||
                operationMode == OperationMode.addToPlaylist)
              SizedBox(
                height: 35,
                //color: Theme.of(context).canvasColor,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Obx(
                            () => Checkbox(
                              value: controller.isAllSelected.value,
                              onChanged: (val) {
                                screenController.selectAll!(val!);
                                controller.toggleSelectAll(val);
                              },
                              visualDensity: const VisualDensity(
                                  horizontal: -3, vertical: -3),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Text(
                          "selectAll".tr,
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ModificationList(
              mode: operationMode,
              screenController: screenController,
            ),
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CancelButton(
                    onPressed: () {
                      controller.setActiveMode(OperationMode.none);
                      screenController.cancelAdditionalOperation!();
                    },
                  ),
                  ProceedButton(
                      buttonText: "Proceed",
                      onPressed: () {
                        Navigator.of(context).pop();
                        screenController.performAdditionalOperation!();
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
