import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_shop/models/products.dart';
import 'package:my_shop/provider/cart_provider.dart';
import 'package:my_shop/provider/product_provider.dart';
import 'package:my_shop/widgets/buttons/custom_primary_button.dart';

class CartBottomBar extends ConsumerWidget {
  const CartBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    double total = 0.0;
    cart.forEach((productId, quantity) {
      final product = ref
          .read(productsProvider)
          .maybeWhen(
            data: (products) => products.firstWhere(
              (p) => p.id == productId,
              orElse: () => Product(
                id: '',
                name: '',
                prevPrice: null,
                presentPrice: 0,
                imageUrl: '',
                description: '',
              ),
            ),
            orElse: () => null,
          );
      if (product != null) {
        total += product.presentPrice * quantity;
      }
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    );
  }
}
