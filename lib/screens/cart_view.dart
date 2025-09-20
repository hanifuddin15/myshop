import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_shop/models/products.dart';
import 'package:my_shop/provider/cart_provider.dart';
import 'package:my_shop/provider/product_provider.dart';
import 'package:my_shop/widgets/appbar/custom_appbar.dart';
import 'package:my_shop/widgets/no_data_widget.dart';
import 'package:my_shop/widgets/product_widgets/cart_bottom_bar.dart';
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

          // final total = ref.read(cartProvider.notifier).getTotal(products);

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
              CartBottomBar(),
            ],
          );
        },
        loading: () => ShimmerCartItemList(),
        error: (_, _) => const Center(child: Text('Error loading cart')),
      ),
    );
  }
}
