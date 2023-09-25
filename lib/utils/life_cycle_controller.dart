import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '/utils/helper.dart';
import 'house_keeping.dart' show removeCachedFileCreatedUsingProxy;

class LifeCycleController extends SuperController {
  @override
  void onDetached() {
    printINFO("detached");
    removeCachedFileCreatedUsingProxy();
  }

  @override
  void onInactive() {
  }

  @override
  void onPaused() {
  }

  @override
  void onResumed() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
