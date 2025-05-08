import 'dart:io';

Future<void> generate() async {
  const filename = './lib/utils/get_localization.dart';

  String allLangData = "";

  var myDir = Directory('./localization');
  myDir.listSync(recursive: true, followLinks: false).forEach((entity) {
    if (entity.uri.toString().contains("generator")) {
      return;
    }
    String fileContent = (entity as File).readAsStringSync();
    String langCode = entity.uri.pathSegments.last.split(".")[0];
    if (langCode == "zh_Hant") {
      langCode = "zh-TW";
    } else if (langCode == "zh_Hans") {
      langCode = "zh-CN";
    }
    allLangData = """$allLangData"$langCode" : $fileContent,""";
  });

  String content = """
// This is auto generated file 
// Do not modify this file manually

import 'package:get/get.dart';
class Languages extends Translations {

@override
Map<String, Map<String, String>> get keys => {
  $allLangData
 };
}""";

  await File(filename).writeAsString(content, mode: FileMode.writeOnly);
}

void main() {
  generate();
}
