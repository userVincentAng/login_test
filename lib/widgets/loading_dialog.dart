import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? baseColor;
  final Color? highlightColor;
  final Color? textColor;

  const LoadingDialog({
    super.key,
    this.message = 'Please wait...',
    this.backgroundColor,
    this.baseColor,
    this.highlightColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Shimmer.fromColors(
              baseColor: baseColor ?? Colors.grey[300]!,
              highlightColor: highlightColor ?? Colors.grey[100]!,
              period: const Duration(milliseconds: 1500),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: baseColor ?? Colors.grey[300]!,
              highlightColor: highlightColor ?? Colors.grey[100]!,
              period: const Duration(milliseconds: 1500),
              child: Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    String message = 'Please wait...',
    Color? backgroundColor,
    Color? baseColor,
    Color? highlightColor,
    Color? textColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => LoadingDialog(
        message: message,
        backgroundColor: backgroundColor,
        baseColor: baseColor,
        highlightColor: highlightColor,
        textColor: textColor,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
