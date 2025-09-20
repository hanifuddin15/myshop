import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:my_shop/core/app_assets.dart';
import 'package:my_shop/provider/cart_provider.dart';
import 'package:my_shop/provider/favourites_provider.dart';
import 'package:my_shop/provider/product_provider.dart';
import 'package:my_shop/widgets/appbar/custom_appbar.dart';
import 'package:my_shop/widgets/image/custom_network_image.dart';
import 'package:my_shop/widgets/no_data_widget.dart';

class FavoriteListScreen extends ConsumerWidget {
  const FavoriteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final favorites = ref.watch(favoritesProvider);
    final productsAsync = ref.watch(productsProvider);

    // Cart count for appbar
    final cartCount = ref.watch(
      cartProvider.select(
        (cart) => cart.values.fold(0, (sum, qty) => sum + qty),
      ),
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Favorites',

        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Colors.deepPurpleAccent,
                  ),
                  onPressed: () => context.go('/cart'),
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 14,
                  top: 4,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      cartCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          // Filter only favorite products
          final favoriteProducts = products
              .where((p) => favorites.contains(p.id))
              .toList();

          if (favoriteProducts.isEmpty) {
            return const Center(
              child: NoDataWidget(message: 'No Favorites Found'),
            );
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                final isInCart = ref
                    .watch(cartProvider)
                    .containsKey(product.id);

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50,
                    child: FadeInAnimation(
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CustomNetworkImage(
                              imageUrl: product.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorImagePath: AppAssets.noProductImage,
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            "\$${product.presentPrice.toStringAsFixed(2)}",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Remove from favorites
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  ref
                                      .read(favoritesProvider.notifier)
                                      .toggle(product.id);
                                },
                              ),
                              // Add to cart
                              IconButton(
                                icon: Icon(
                                  isInCart
                                      ? Icons.check_circle
                                      : Icons.add_shopping_cart,
                                  color: isInCart
                                      ? Colors.green
                                      : Colors.deepPurpleAccent,
                                ),
                                onPressed: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addToCart(product.id, context);
                                },
                              ),
                            ],
                          ),
                          onTap: () => context.go(
                            '/product/${product.id}',
                          ), // go details
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
        error: (error, _) =>
            Center(child: NoDataWidget(message: 'Error: $error')),
      ),
    );
  }
}
