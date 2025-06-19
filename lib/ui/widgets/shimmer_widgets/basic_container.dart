import 'package:flutter/material.dart';

class BasicShimmerContainer extends StatelessWidget {
  const BasicShimmerContainer(this.size, {super.key, this.radius = 10});
  final Size size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius), color: Colors.white54),
      height: size.height,
      width: size.width,
    );
  }
}
