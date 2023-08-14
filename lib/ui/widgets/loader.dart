import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double strokeWidth;
  const LoadingIndicator({super.key,this.strokeWidth = 4});
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: 25, child: CircularProgressIndicator(strokeWidth: strokeWidth,));
  }
}