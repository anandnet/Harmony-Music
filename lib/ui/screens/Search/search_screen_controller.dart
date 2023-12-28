import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/music_service.dart';

class SearchScreenController extends GetxController {
  final textInputController = TextEditingController();
  final musicServices = Get.find<MusicServices>();
  final suggestionList = [].obs;

  Future<void> onChanged(String text) async {
    suggestionList.value = await musicServices.getSearchSuggestion(text);
  }

  Future<void> suggestionInput(String txt) async {
    textInputController.text = txt;
    textInputController.selection =
        TextSelection.collapsed(offset: textInputController.text.length);
    await onChanged(txt);
  }

  @override
  void dispose() {
    textInputController.dispose();
    super.dispose();
  }
}
