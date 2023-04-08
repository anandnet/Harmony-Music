import 'package:flutter/foundation.dart';

void printERROR(dynamic text,{String tag="Harmony Music"}){
  debugPrint("\x1B[31m[$tag]: $text");
}

void printWarning(dynamic text, {String tag='Harmony Music'}){
  debugPrint("\x1B[33m[$tag]: $text");
}

void printINFO(dynamic text, {String tag='Harmony Music'}){
  debugPrint("\x1B[32m[$tag]: $text");
}