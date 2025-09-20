import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_shop/widgets/image/custom_network_image.dart';

class ProductImageCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final bool hasDiscount;
  final int? discountPercent;

  const ProductImageCard({
    super.key,
    required this.id,
    required this.imageUrl,
    this.hasDiscount = false,
    this.discountPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: id,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: CustomNetworkImage(
              imageUrl: imageUrl,
              height: 350.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Discount Badge
        if (hasDiscount && discountPercent != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "-$discountPercent%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Back Button
        Positioned(
          top: 40,
          left: 25,
          child: CircleAvatar(
            backgroundColor: Colors.white70,
            radius: 20,
            child: IconButton(
              icon: const Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Icon(Icons.arrow_back_ios, size: 20),
              ),
              onPressed: () => context.go('/'),
            ),
          ),
        ),
      ],
    );
  }
}
