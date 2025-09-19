import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_shop/provider/cart_provider.dart';
import 'package:my_shop/provider/product_provider.dart';


class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final productsAsync = ref.watch(productsProvider);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: const Center(child: Text('Your cart is empty')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: productsAsync.when(
        data: (products) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final entry = cart.entries.elementAt(index);
                    final product = products.firstWhere((p) => p.id == entry.key);
                    return Card(
                      child: ListTile(
                        leading: Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(product.name),
                        subtitle: Text('\$${product.price.toStringAsFixed(2)} each'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => ref.read(cartProvider.notifier).updateQuantity(entry.key, entry.value - 1),
                            ),
                            Text('${entry.value}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => ref.read(cartProvider.notifier).updateQuantity(entry.key, entry.value + 1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => ref.read(cartProvider.notifier).removeFromCart(entry.key),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Total: \$${ref.read(cartProvider.notifier).getTotal(products).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => context.go('/checkout'),
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading cart')),
      ),
    );
  }
}