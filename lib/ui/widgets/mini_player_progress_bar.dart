import 'package:flutter/material.dart';

class MiniPlayerProgressBar extends StatelessWidget {
  const MiniPlayerProgressBar({super.key, this.total =Duration.zero, this.current=Duration.zero,required this.progressBarColor});
  final Duration current;
  final Duration total;
  final Color progressBarColor;
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 3),
      painter: ProgressBarPainter(current: current,total: total,progressBarColor: progressBarColor),
    );
  }
}

class ProgressBarPainter extends CustomPainter {
  ProgressBarPainter({required this.current, required this.total,required this.progressBarColor});
  final Duration current;
  final Duration total;
  final Color progressBarColor;
  @override
  void paint(Canvas canvas, Size size) {
    const p1 = Offset(0, 1.5);
    final p2 = Offset(size.width * (current.inSeconds / total.inSeconds), 1.5);
    final paint = Paint()
      ..color = progressBarColor
      ..strokeWidth = 3 ..strokeCap=StrokeCap.round;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
