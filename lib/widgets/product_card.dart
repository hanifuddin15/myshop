import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_shop/models/products.dart';
import 'package:my_shop/provider/favourites_provider.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider.select((state) => state.contains(product.id)));

    return GestureDetector(
      onTap: () => context.go('/product/${product.id}'),
      child: Hero(
        tag: product.id,
        child: Card(
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: Theme.of(context).textTheme.titleMedium),
                      Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            transform: Matrix4.identity()..scale(isFavorite ? 1.2 : 1.0),
                            child: IconButton(
                              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                              onPressed: () => ref.read(favoritesProvider.notifier).toggle(product.id),
                              color: isFavorite ? Colors.red : null,
                            ),
                          ),
                          FilledButton(
                            onPressed: () {
                              context.go('/product/${product.id}');
                            },
                            child: const Text('View'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}