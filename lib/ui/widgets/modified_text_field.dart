import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModifiedTextField extends StatelessWidget {
  final TextEditingController? controller;
  final Color? cursorColor;
  final InputDecoration? decoration;
  final bool obscureText;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;

  const ModifiedTextField(
      {super.key,
      this.controller,
      this.cursorColor,
      this.decoration,
      this.obscureText = false,
      this.textAlign = TextAlign.start,
      this.textAlignVertical,
      this.autofocus = false,
      this.textCapitalization = TextCapitalization.none,
      this.textInputAction,
      this.onSubmitted,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.space):
              const DoNothingAndStopPropagationTextIntent()
        },
        child: TextField(
            controller: controller,
            cursorColor: cursorColor,
            decoration: decoration,
            obscureText: obscureText,
            textAlign: textAlign,
            textAlignVertical: textAlignVertical,
            autofocus: autofocus,
            onChanged: onChanged,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            textCapitalization: textCapitalization));
  }
}
