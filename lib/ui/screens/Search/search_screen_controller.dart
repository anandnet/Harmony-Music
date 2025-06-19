import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '/utils/app_link_controller.dart' show ProcessLink;
import '/services/music_service.dart';

class SearchScreenController extends GetxController with ProcessLink {
  final textInputController = TextEditingController();
  final musicServices = Get.find<MusicServices>();
  final suggestionList = [].obs;
  final historyQuerylist = [].obs;
  late Box<dynamic> queryBox;
  final urlPasted = false.obs;

  // Desktop search bar related
  final focusNode = FocusNode();
  final isSearchBarInFocus = false.obs;

  @override
  onInit() {
    _init();
    super.onInit();
  }

  _init() async {
    if(GetPlatform.isDesktop){
      focusNode.addListener((){
        isSearchBarInFocus.value = focusNode.hasFocus;
      });
    }
    queryBox = await Hive.openBox("searchQuery");
    historyQuerylist.value = queryBox.values.toList().reversed.toList();
  }

  Future<void> onChanged(String text) async {
    if(text.contains("https://")){
      urlPasted.value = true; 
      return;
    }
    urlPasted.value = false;
    suggestionList.value = await musicServices.getSearchSuggestion(text);
  }

  Future<void> suggestionInput(String txt) async {
    textInputController.text = txt;
    textInputController.selection =
        TextSelection.collapsed(offset: textInputController.text.length);
    await onChanged(txt);
  }

  Future<void> addToHistryQueryList(String txt) async {
    if (historyQuerylist.length > 9) {
      final queryForRemoval = queryBox.getAt(0);
      await queryBox.deleteAt(0);
      historyQuerylist.removeWhere((element) => element == queryForRemoval);
    }
    if (!historyQuerylist.contains(txt)) {
      await queryBox.add(txt);
      historyQuerylist.insert(0, txt);
    }

    //reset current query and suggestionlist
    reset();
  }

  void reset() {
    urlPasted.value = false;
    textInputController.text = "";
    suggestionList.clear();
  }

  Future<void> removeQueryFromHistory(String txt) async {
    final index = queryBox.values.toList().indexOf(txt);
    await queryBox.deleteAt(index);
    historyQuerylist.remove(txt);
  }

  @override
  void dispose() {
    focusNode.dispose();
    textInputController.dispose();
    queryBox.close();
    super.dispose();
  }
}
