import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_shop/models/products.dart';
import 'package:my_shop/provider/favourites_provider.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(
      favoritesProvider.select((state) => state.contains(product.id)),
    );

    // Discount calculation
    double? discount;
    if (product.prevPrice != null &&
        product.prevPrice! > product.presentPrice) {
      discount =
          ((product.prevPrice! - product.presentPrice) / product.prevPrice!) *
          100;
    }

    return GestureDetector(
      onTap: () => context.go('/product/${product.id}'),
      child: Hero(
        tag: product.id,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // IMAGE + BADGES
              AspectRatio(
                aspectRatio: 3 / 2,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: theme.colorScheme.surfaceContainer,
                              highlightColor: theme.colorScheme.surface,
                              child: Container(
                                color: theme.colorScheme.surfaceContainer,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: theme.colorScheme.errorContainer,
                            child: Icon(
                              Icons.error,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (discount != null)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${discount.toStringAsFixed(0)}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: AnimatedScale(
                        scale: isFavorite ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: IconButton.filledTonal(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                          ),
                          onPressed: () => ref
                              .read(favoritesProvider.notifier)
                              .toggle(product.id),
                          color: isFavorite ? Colors.deepPurpleAccent : null,
                          padding: const EdgeInsets.all(2),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // DETAILS
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 1),

                    // Price
                    Row(
                      children: [
                        Text(
                          '\$${product.presentPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (product.prevPrice != null &&
                            product.prevPrice! > product.presentPrice) ...[
                          const SizedBox(width: 3),
                          Text(
                            '\$${product.prevPrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.red,
                              decorationThickness: 2,
                              decorationStyle: TextDecorationStyle.solid,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),

                    // Rating
                    if (product.rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 11,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.rating!.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          if (product.review != null) ...[
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '(${product.review})',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    const SizedBox(height: 7),

                    // CTA
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: FilledButton.tonal(
                        onPressed: () => context.go('/product/${product.id}'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('View'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
