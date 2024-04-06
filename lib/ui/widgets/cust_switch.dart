import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';

class CustSwitch extends StatelessWidget {
  const CustSwitch({super.key, this.onChanged, required this.value});
  final void Function(bool)? onChanged;
  final bool value;

  @override
  Widget build(BuildContext context) {
    final isLightMode =
        Get.find<ThemeController>().themedata.value!.primaryColor ==
            Colors.white;
    return Switch(
        activeColor: Colors.white,
        activeTrackColor: isLightMode ? Colors.grey : null,
        inactiveTrackColor: isLightMode ? Colors.grey : null,
        inactiveThumbColor:
            isLightMode ? Colors.grey[300] : Colors.white.withOpacity(0.5),
        value: value,
        onChanged: onChanged);
  }
}
