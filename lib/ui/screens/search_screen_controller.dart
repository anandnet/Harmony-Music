import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/music_service.dart';

class SearchScreenController extends GetxController{
   final textInputController = TextEditingController();
   final musicServices = Get.find<MusicServices>();
   final suggestionList = [].obs;

   Future<void> onChanged(String text) async {
      suggestionList.value = await musicServices.getSearchSuggestion(text);
   }

}