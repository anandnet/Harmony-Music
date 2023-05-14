import 'package:flutter/material.dart';

SnackBar snackbar(BuildContext context, String text, double width) {
  return SnackBar(
    backgroundColor: Theme.of(context).colorScheme.secondary,
    content: Text(
      text,
      style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black),
    ),
    //width: width,

    margin: const EdgeInsets.only(bottom: 100.0, left: 40, right: 40),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}
