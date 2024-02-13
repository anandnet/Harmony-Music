import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class AnimatedScreenTransition extends StatelessWidget {
  const AnimatedScreenTransition(
      {super.key,
      this.enabled = true,
      this.resverse = false,
      this.horizontalTransition = false,
      required this.child});
  final bool enabled;
  final bool resverse;
  final Widget child;
  final bool horizontalTransition;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    Tween<Offset> forwardTween;
    Tween<Offset> reverseTween;
    if (horizontalTransition) {
      forwardTween = resverse
          ? Tween<Offset>(begin: Offset.zero, end: const Offset(-1, 0))
          : Tween<Offset>(begin: Offset.zero, end: const Offset(1, 0));
      reverseTween = resverse
          ? Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          : Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero);
    } else {
      forwardTween = resverse
          ? Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1))
          : Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1));
      reverseTween = resverse
          ? Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          : Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero);
    }
    return PageTransitionSwitcher(
      duration: horizontalTransition
          ? const Duration(milliseconds: 400)
          : const Duration(milliseconds: 450),
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return DualTransitionBuilder(
          animation: primaryAnimation,
          forwardBuilder: (context, animation, child) => SlideTransition(
            position: forwardTween.animate(primaryAnimation),
            child: child,
          ),
          reverseBuilder: (context, animation, child) => SlideTransition(
            position: reverseTween.animate(secondaryAnimation),
            child: child,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}
