import 'package:flutter/material.dart';

class CommonDialog extends StatelessWidget {
  const CommonDialog({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: child,
          )),
    );
  }
}
