import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/main.dart';
import 'package:my_shop/models/products.dart';
import '../data/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(ref.watch(sharedPreferencesProvider)),
);

final productsProvider = AsyncNotifierProvider<ProductNotifier, List<Product>>(
  ProductNotifier.new,
);

class ProductNotifier extends AsyncNotifier<List<Product>> {
  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _isLoadingMore = false;

  @override
  Future<List<Product>> build() async {
    final repo = ref.watch(productRepositoryProvider);
    return repo.getProducts(_currentPage, _pageSize);
  }
  //======================= Pull to Refresh =============================//

  Future<void> refresh() async {
    _currentPage = 1;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(productRepositoryProvider)
          .getProducts(_currentPage, _pageSize),
    );
  }
  //=======================Load More Product=============================//

  Future<void> loadMore() async {
    if (_isLoadingMore || state.value == null) return;
    _isLoadingMore = true;
    final repo = ref.read(productRepositoryProvider);
    final totalProducts = repo.getTotalProducts();
    final currentLength = state.value?.length ?? 0;
    if (currentLength >= totalProducts) return;

    _currentPage++;
    final newProducts = await repo.getProducts(_currentPage, _pageSize);
    if (newProducts.isNotEmpty) {
      state = AsyncValue.data([...state.value!, ...newProducts]);
    }
    _isLoadingMore = false;
  }
  //======================= Search Products=============================//

  List<Product> search(String query) {
    final products = state.value ?? [];
    if (query.isEmpty) return products;
    return products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
