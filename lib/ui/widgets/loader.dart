import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double strokeWidth;
  final double? value;
  final double dimension;
  const LoadingIndicator(
      {super.key, this.strokeWidth = 4, this.dimension = 25, this.value});
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
        dimension: dimension,
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: strokeWidth,
          color: Theme.of(context).textTheme.titleLarge!.color,
        ));
  }
}
