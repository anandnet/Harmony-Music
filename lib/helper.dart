import 'package:flutter/foundation.dart';

void printERROR(String text,{String tag="Harmony Music"}){
  debugPrint("\x1B[31m[$tag]: $text");
}

void printWarning(String text, {String tag='Harmony Music'}){
  debugPrint("\x1B[33m[$tag]: $text");
}

void printINFO(String text, {String tag='Harmony Music'}){
  debugPrint("\x1B[32m[$tag]: $text");
}