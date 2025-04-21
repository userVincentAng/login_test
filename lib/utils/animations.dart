import 'package:flutter/material.dart';

class CustomAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxShadow? shadow;
  final VoidCallback? onTap;

  const CustomAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.shadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: shadow != null ? [shadow!] : null,
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: child,
            )
          : child,
    );
  }
}

class AnimatedOpacity extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double opacity;
  final bool visible;

  const AnimatedOpacity({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.opacity = 1.0,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: duration,
      curve: curve,
      opacity: visible ? opacity : 0.0,
      child: child,
    );
  }
}

class AnimatedScale extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double scale;
  final bool visible;

  const AnimatedScale({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.scale = 1.0,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: duration,
      curve: curve,
      scale: visible ? scale : 0.0,
      child: child,
    );
  }
}
