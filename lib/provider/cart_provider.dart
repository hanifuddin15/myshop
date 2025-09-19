import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_shop/models/products.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';  // For sharedPreferencesProvider

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, int>>(
  (ref) => CartNotifier(ref.watch(sharedPreferencesProvider)),
);

class CartNotifier extends StateNotifier<Map<String, int>> {
  final SharedPreferences prefs;

  CartNotifier(this.prefs)
      : super(
          (jsonDecode(prefs.getString('cart') ?? '{}') as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value as int)),
        );

  void addToCart(String id) {
    final newCart = Map<String, int>.from(state);
    newCart[id] = (newCart[id] ?? 0) + 1;
    state = newCart;
    prefs.setString('cart', jsonEncode(newCart));
  }

  void removeFromCart(String id) {
    final newCart = Map<String, int>.from(state);
    newCart.remove(id);
    state = newCart;
    prefs.setString('cart', jsonEncode(newCart));
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeFromCart(id);
      return;
    }
    final newCart = Map<String, int>.from(state);
    newCart[id] = quantity;
    state = newCart;
    prefs.setString('cart', jsonEncode(newCart));
  }

  double getTotal(List<Product> products) {
    return state.entries.fold<double>(0, (sum, entry) {
      final product = products.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => Product(id: '', name: '', price: 0, imageUrl: '', description: ''),
      );
      return sum + product.price * entry.value;
    });
  }

  void clearCart() {
    state = {};
    prefs.setString('cart', jsonEncode({}));
  }

  bool get isEmpty => state.isEmpty;
}