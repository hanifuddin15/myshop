import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_shop/models/products.dart';
import 'package:my_shop/utility/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

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

  //======================= Add To Cart=============================//
  void addToCart(String id, BuildContext context) {
    try {
      final newCart = Map<String, int>.from(state);
      newCart[id] = (newCart[id] ?? 0) + 1;
      state = newCart;
      _saveCart();
      showCustomSnackbar(context, message: 'Item added to cart!');
    } catch (e) {
      showCustomSnackbar(
        context,
        message: 'Failed to add item!',
        isError: true,
      );
    }
  }
  //======================= Remove From Cart=============================//

  void removeFromCart(String id) {
    final newCart = Map<String, int>.from(state);
    newCart.remove(id);
    state = newCart;
    _saveCart();
  }
  //======================= Update Cart Counts=============================//

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeFromCart(id);
      return;
    }
    final newCart = Map<String, int>.from(state);
    newCart[id] = quantity;
    state = newCart;
    _saveCart();
  }

  //======================= Get Total=============================//

  double getTotal(List<Product> products) {
    return state.entries.fold<double>(0, (sum, entry) {
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
      return sum + product.presentPrice * entry.value;
    });
  }
  //======================= Clear Cart=============================//

  void clearCart() {
    state = {};
    _saveCart();
  }

  //==========================Is Empty===========================//
  bool get isEmpty => state.isEmpty;
  //======================= Save Cart Cart=============================//

  void _saveCart() => prefs.setString('cart', jsonEncode(state));
}
