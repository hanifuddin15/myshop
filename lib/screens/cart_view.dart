import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_shop/models/products.dart';
import 'package:my_shop/provider/cart_provider.dart';
import 'package:my_shop/provider/product_provider.dart';
import 'package:my_shop/widgets/appbar/custom_appbar.dart';
import 'package:my_shop/widgets/buttons/custom_primary_button.dart';
import 'package:my_shop/widgets/no_data_widget.dart';
import 'package:my_shop/widgets/product_widgets/shop_cart.dart';
import 'package:my_shop/widgets/shimmer/cart_shimmer.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: CustomAppBar(title: 'Cart'),
      body: productsAsync.when(
        data: (products) {
          if (cart.isEmpty) {
            return NoDataWidget(
              message: 'Your Cart is Empty. Go Home to Add to Cart',
              buttonText: 'Go Home',
              icon: Icons.remove_shopping_cart,
              onAction: () {
                context.go('/');
              },
            );
          }

          final total = ref.read(cartProvider.notifier).getTotal(products);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = cart.entries.elementAt(index);
                    final product = products.firstWhere(
                      (p) => p.id == entry.key,
                      orElse: () => Product(
                        id: '',
                        name: '',
                        prevPrice: null,
                        presentPrice: 0,
                        imageUrl: '',
                        description: '',
                      ),
                    );

                    return ShopCart(product: product);
                  },
                ),
              ),

              // Total & Checkout
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurpleAccent,
                                fontSize: 18,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: CustomPrimaryButton(
                        title: 'Proceed to Checkout',
                        onPressed: () => context.go('/checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => ShimmerCartItemList(),
        error: (_, _) => const Center(child: Text('Error loading cart')),
      ),
    );
  }
}
