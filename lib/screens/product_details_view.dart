import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/provider/cart_provider.dart';
import 'package:my_shop/provider/favourites_provider.dart';
import 'package:my_shop/provider/product_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String id;

  const ProductDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: productsAsync.when(
        data: (products) {
          final product = products.firstWhere((p) => p.id == id);
          final isFavorite = ref.watch(favoritesProvider.select((state) => state.contains(id)));

          return SingleChildScrollView(
            child: Column(
              children: [
                Hero(
                  tag: id,
                  child: Image.network(product.imageUrl, height: 300, width: double.infinity, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
                      Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.green)),
                      const SizedBox(height: 8),
                      Text(product.description),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: IconButton(
                              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                              onPressed: () => ref.read(favoritesProvider.notifier).toggle(id),
                              color: isFavorite ? Colors.red : null,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => ref.read(cartProvider.notifier).addToCart(id),
                            child: const Text('Add to Cart'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading product')),
      ),
    );
  }
}