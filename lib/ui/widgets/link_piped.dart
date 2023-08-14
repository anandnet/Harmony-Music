import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/helper.dart';
import '/services/piped_service.dart';
import '/ui/screens/settings_screen_controller.dart';
import '/ui/utils/home_library_controller.dart';
import 'snackbar.dart';

class LinkPiped extends StatelessWidget {
  const LinkPiped({super.key});

  @override
  Widget build(BuildContext context) {
    final pipedLinkedController = Get.put(PipedLinkedController());
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          height: 365,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Piped",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                child: Obx(() => DropdownButton(
                    value: pipedLinkedController.selectedInst.value,
                    items: pipedLinkedController.pipedInstList
                        .map(
                          (element) => DropdownMenuItem(
                              value: element.apiUrl, child: Text(element.name)),
                        )
                        .toList(),
                    onChanged: (val) {
                      pipedLinkedController.selectedInst.value = val as String;
                    })),
              ),
              TextField(
                  controller: pipedLinkedController.usernameInputController,
                  cursorColor: Theme.of(context).textTheme.titleSmall!.color,
                  decoration: const InputDecoration(hintText: "Username")),
              const SizedBox(
                height: 15,
              ),
              Obx(() => TextField(
                    controller: pipedLinkedController.passwordInputController,
                    cursorColor: Theme.of(context).textTheme.titleSmall!.color,
                    decoration: InputDecoration(
                      hintText: "Password",
                      suffixIcon: IconButton(
                        color: Theme.of(context).textTheme.titleSmall!.color,
                        icon: pipedLinkedController.passwordVisible.value
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                        onPressed: () =>
                            pipedLinkedController.passwordVisible.value =
                                !pipedLinkedController.passwordVisible.value,
                      ),
                    ),
                    obscureText: !pipedLinkedController.passwordVisible.value,
                  )),
              Expanded(
                  child: Obx(() => Center(
                          child: Text(
                        pipedLinkedController.errorText.value,
                        textAlign: TextAlign.center,
                      )))),
              Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.titleLarge!.color,
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: pipedLinkedController.link,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Text(
                        "Link",
                        style: TextStyle(color: Theme.of(context).canvasColor),
                      ),
                    ),
                  )),
            ],
          ),
        ));
  }
}

class PipedLinkedController extends GetxController {
  final usernameInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  final pipedInstList = <PipedInstance>[
    PipedInstance(name: "Select Auth Instance        ", apiUrl: "")
  ].obs;
  final selectedInst = "".obs;
  final _pipedServices = Get.find<PipedServices>();
  final passwordVisible = false.obs;
  final errorText = "".obs;

  @override
  void onInit() {
    getAllInstList();
    super.onInit();
  }

  Future<void> getAllInstList() async {
    _pipedServices.getAllInstanceList().then((res) {
      if (res.code == 1) {
        pipedInstList.addAll(List<PipedInstance>.from(res.response));
      }
    });
  }

  void link() {
    errorText.value = "";
    final userName = usernameInputController.text;
    final password = passwordInputController.text;
    if (selectedInst.isEmpty) {
      errorText.value = "Please select Authentication instance!";
      return;
    }
    if (userName.isEmpty || password.isEmpty) {
      errorText.value = "All fields required";
      return;
    }
    _pipedServices
        .login(selectedInst.toString(), userName, password)
        .then((res) {
      if (res.code == 1) {
        printINFO("Login Successfull");
        Get.find<SettingsScreenController>().isLinkedWithPiped.value = true;
        Navigator.of(Get.context!).pop();
        ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
            Get.context!, "Linked successfully!",
            size: SanckBarSize.MEDIUM));
        Get.find<LibraryPlaylistsController>().syncPipedPlaylist();
      } else {
        errorText.value = res.errorMessage ?? "Error occurred!";
      }
    });
  }
}
