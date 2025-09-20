import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_shop/provider/cart_provider.dart';
import 'package:my_shop/provider/favourites_provider.dart';
import 'package:my_shop/provider/product_provider.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String id;

  const ProductDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      body: productsAsync.when(
        data: (products) {
          final product = products.firstWhere((p) => p.id == id);
          final isFavorite = ref.watch(
            favoritesProvider.select((state) => state.contains(id)),
          );

          final hasDiscount =
              product.prevPrice != null &&
              product.prevPrice! > product.presentPrice;
          final discountPercent = hasDiscount
              ? (((product.prevPrice! - product.presentPrice) /
                            product.prevPrice!) *
                        100)
                    .round()
              : null;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Stack(
                      children: [
                        Hero(
                          tag: id,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            child: Image.network(
                              product.imageUrl,
                              height: 350,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 350,
                                    width: double.infinity,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (hasDiscount)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
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
                        Positioned(
                          top: 40,
                          left: 25,
                          child: CircleAvatar(
                            backgroundColor: Colors.white70,
                            radius: 20,
                            child: IconButton(
                              icon: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 20,
                                ),
                              ),
                              onPressed: () => context.go('/'),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Product Info Card
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),

                              // Price Row
                              Row(
                                children: [
                                  Text(
                                    "\$${product.presentPrice.toStringAsFixed(2)}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: Colors.green),
                                  ),
                                  if (hasDiscount) ...[
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        "\$${product.prevPrice!.toStringAsFixed(2)}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              decoration:
                                                  TextDecoration.lineThrough,
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
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.rating!.toStringAsFixed(1),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    if (product.review != null) ...[
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          "(${product.review})",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
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
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.deepPurpleAccent
                                        : Colors.grey,
                                    size: 30,
                                  ),
                                  onPressed: () => ref
                                      .read(favoritesProvider.notifier)
                                      .toggle(id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // Bottom Add to Cart Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => ref
                              .read(cartProvider.notifier)
                              .addToCart(id, context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.deepPurpleAccent,
                            elevation: 4,
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => _buildShimmerDetail(),
        error: (_, __) =>
            const Center(child: Text('Error loading product details')),
      ),
    );
  }

  Widget _buildShimmerDetail() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 350, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 24, width: 200, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(height: 20, width: 100, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(height: 40, width: 40, color: Colors.white),
                      const SizedBox(width: 16),
                      Container(height: 40, width: 120, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
