import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';

import '../screens/settings_screen_controller.dart';

class ProxyPopup extends StatelessWidget {
  const ProxyPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final proxyPopupController = Get.put(ProxyPopupController());
    printINFO("build");
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: 255,
        padding:
            const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 20),
        child: Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Proxy Host",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextField(
            controller: proxyPopupController.hostInputController,
            autofocus: true,
            cursorColor: Theme.of(context).textTheme.titleSmall!.color,
            decoration: const InputDecoration(hintText: "eg: 127.0.0.1"),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Proxy Port",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          TextField(
            controller: proxyPopupController.portInputController,
            keyboardType: TextInputType.number,
            cursorColor: Theme.of(context).textTheme.titleSmall!.color,
            decoration: const InputDecoration(hintText: "eg: 8080"),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Cancel"),
                  ),
                  onTap: () => Navigator.of(context).pop(),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.titleLarge!.color,
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: proxyPopupController.setProxy,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10),
                      child: Text(
                        "Ok",
                        style: TextStyle(color: Theme.of(context).canvasColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class ProxyPopupController extends GetxController {
  final hostInputController = TextEditingController();
  final portInputController = TextEditingController();
  final settingsScreenController = Get.find<SettingsScreenController>();

  @override
  void onInit() {
    printINFO("Init called");
    final proxy = settingsScreenController.proxy.value.split(":");
    hostInputController.text = proxy[0];
    portInputController.text = proxy[1];
    super.onInit();
  }

  void setProxy() async {
    final proxy = "${hostInputController.text}:${portInputController.text}";
    Hive.box("AppPrefs").put("proxy", proxy).then((value) {
      settingsScreenController.proxy.value = proxy;
      Navigator.of(Get.context!).pop();
    });
  }

  @override
  void onClose() {
    hostInputController.dispose();
    portInputController.dispose();
    super.onClose();
  }
}
