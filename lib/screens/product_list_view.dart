import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:my_shop/provider/favourites_provider.dart';
import 'package:my_shop/provider/product_provider.dart';
import 'package:my_shop/provider/cart_provider.dart'; // Import the correct cartProvider
import 'package:my_shop/widgets/no_data_widget.dart';
import 'package:my_shop/widgets/shimmer/product_list_shimmer.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    ref.read(productsProvider.notifier).loadMore();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      ref
          .read(productsProvider.notifier)
          .loadMore()
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider);
    final searchQuery = _searchController.text;

    // Counters
    final favoritesCount = ref.watch(favoritesProvider).length;
    final cartCount = ref.watch(
      cartProvider.select(
        (cart) => cart.values.fold(0, (sum, qty) => sum + qty),
      ),
    ); // Total items in cart

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: const Text(
          'My Shop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.deepPurpleAccent,
          ),
        ),
        actions: [
          // Favorites Counter
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => context.go('/favorites'),
              ),
              if (favoritesCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.redAccent,
                    child: Text(
                      favoritesCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),

          // Cart Counter
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.deepPurpleAccent,
                ),
                onPressed: () => context.go('/cart'),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 4,
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
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(productsProvider.notifier).refresh();
          setState(() {});
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: theme.colorScheme.primary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.outlineVariant.withAlpha(100),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            productsAsync.when(
              data: (products) {
                final filteredProducts = ref
                    .read(productsProvider.notifier)
                    .search(searchQuery);
                if (filteredProducts.isEmpty) {
                  return SliverFillRemaining(
                    child: NoDataWidget(message: 'No Products Found'),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 3
                          : 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredProducts[index];
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          columnCount: 2,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            child: FadeInAnimation(
                              child: ProductCard(product: product),
                            ),
                          ),
                        );
                      },
                      childCount:
                          filteredProducts.length + (_isLoadingMore ? 1 : 0),
                    ),
                  ),
                );
              },
              loading: () => SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 100,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $error',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () =>
                            ref.read(productsProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const ProductListShimmer(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
