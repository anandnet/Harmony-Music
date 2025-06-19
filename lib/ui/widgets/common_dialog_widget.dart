import 'package:flutter/material.dart';

class CommonDialog extends StatelessWidget {
  const CommonDialog({super.key, this.child, this.maxWidth = 500});
  final double maxWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: child,
          )),
    );
  }
}
