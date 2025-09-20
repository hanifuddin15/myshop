import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/provider/cart_provider.dart';
import 'package:my_shop/provider/favourites_provider.dart';
import 'package:my_shop/provider/product_provider.dart';
import 'package:my_shop/widgets/buttons/custom_primary_button.dart';
import 'package:my_shop/widgets/no_data_widget.dart';
import 'package:my_shop/widgets/product_widgets/product_image_card.dart';
import 'package:my_shop/widgets/product_widgets/product_info_card.dart';
import 'package:my_shop/widgets/shimmer/product_details_shimmer.dart';

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

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ProductImageCard(
                      id: product.id,
                      imageUrl: product.imageUrl,
                      hasDiscount:
                          product.prevPrice != null &&
                          product.prevPrice! > product.presentPrice,
                      discountPercent: product.prevPrice != null
                          ? (((product.prevPrice! - product.presentPrice) /
                                        product.prevPrice!) *
                                    100)
                                .round()
                          : null,
                    ),

                    // Product Info Card
                    ProductInfoCard(
                      product: product,
                      isFavorite: isFavorite,
                      id: product.id,
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
                        child: CustomPrimaryButton(
                          title: 'Add to Cart',
                          height: 52,
                          fontSize: 18,
                          onPressed: () => ref
                              .read(cartProvider.notifier)
                              .addToCart(id, context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => ProductDetailsShimmerLoader(),
        error: (_, _) =>
            const NoDataWidget(message: 'Error Loading Product Details'),
      ),
    );
  }
}
