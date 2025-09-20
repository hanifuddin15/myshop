import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double? width;
  final BoxFit fit;
  final String? errorImagePath;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.height = 350.0,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.errorImagePath,
  });

  static const String _defaultErrorImagePath =
      'assets/images/default_product_placeholder.png';

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(height: height, width: width, color: Colors.white),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          errorImagePath ?? _defaultErrorImagePath,
          height: height,
          width: width,
          fit: fit,
        );
      },
    );
  }
}
