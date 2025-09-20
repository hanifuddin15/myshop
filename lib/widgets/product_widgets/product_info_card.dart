import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/models/products.dart';
import 'package:my_shop/provider/favourites_provider.dart';

class ProductInfoCard extends ConsumerWidget {
  final Product product;
  final bool isFavorite;
  final String id;

  const ProductInfoCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.id,
  });

  bool get hasDiscount =>
      product.prevPrice != null && product.prevPrice! > product.presentPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Price Row
              Row(
                children: [
                  Text(
                    "\$${product.presentPrice.toStringAsFixed(2)}",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.green),
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        "\$${product.prevPrice!.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Rating Row
              if (product.rating != null)
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      product.rating!.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (product.review != null) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "(${product.review})",
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 16),

              // Description
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Favorite Button
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.deepPurpleAccent : Colors.grey,
                    size: 30,
                  ),
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).toggle(id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
