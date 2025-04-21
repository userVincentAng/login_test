import 'package:flutter/material.dart';

class PerformanceUtils {
  static Widget buildOptimizedList({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    EdgeInsets? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    bool addAutomaticKeepAlive = true,
    bool addRepaintBoundary = true,
  }) {
    return ListView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        Widget child = itemBuilder(context, index);

        if (addAutomaticKeepAlive) {
          child = AutomaticKeepAlive(
            key: ValueKey('keep_alive_$index'),
            child: child,
          );
        }

        if (addRepaintBoundary) {
          child = RepaintBoundary(child: child);
        }

        return child;
      },
    );
  }

  static Widget buildOptimizedGrid({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    EdgeInsets? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    bool addAutomaticKeepAlive = true,
    bool addRepaintBoundary = true,
  }) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        Widget child = itemBuilder(context, index);

        if (addAutomaticKeepAlive) {
          child = AutomaticKeepAlive(
            key: ValueKey('keep_alive_$index'),
            child: child,
          );
        }

        if (addRepaintBoundary) {
          child = RepaintBoundary(child: child);
        }

        return child;
      },
    );
  }
}
