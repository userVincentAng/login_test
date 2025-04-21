import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;
  final Duration duration;
  final Curve curve;

  CustomPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
              child: child,
            );
          },
        );
}

class CustomSlidePageRoute extends PageRouteBuilder {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AxisDirection direction;

  CustomSlidePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.direction = AxisDirection.right,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: _getBeginOffset(direction),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: curve,
              )),
              child: child,
            );
          },
        );

  static Offset _getBeginOffset(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.right:
        return const Offset(-1, 0);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
    }
  }
}
