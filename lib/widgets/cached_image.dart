import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? errorBuilder;
  final Widget Function(BuildContext, String, DownloadProgress)?
      progressBuilder;
  final Color? placeholderColor;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.progressBuilder,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: placeholderColor ?? Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: errorBuilder != null
          ? (context, url, error) => errorBuilder!(context, error.toString())
          : (context, url, error) => Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: const Icon(Icons.error_outline),
              ),
      progressIndicatorBuilder: progressBuilder,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }
}
