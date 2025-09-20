// test/cart_notifier_test.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shop/main.dart';
import 'package:my_shop/models/products.dart';
import 'package:my_shop/provider/cart_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CartNotifier', () {
    test('initial state is empty', () {
      final notifier = container.read(cartProvider.notifier);
      expect(notifier.state, isEmpty);
    });

    test('addToCart adds new item', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addToCart(
        '1',
        /* mock context */ TestWidgetsFlutterBinding.ensureInitialized()
            as BuildContext,
      );
      expect(notifier.state['1'], 1);
    });

    test('addToCart increments existing item', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addToCart(
        '1',
        /* mock */ TestWidgetsFlutterBinding.ensureInitialized()
            as BuildContext,
      );
      notifier.addToCart(
        '1',
        /* mock */ TestWidgetsFlutterBinding.ensureInitialized()
            as BuildContext,
      );
      expect(notifier.state['1'], 2);
    });

    test('removeFromCart removes item', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addToCart(
        '1',
        /* mock */ TestWidgetsFlutterBinding.ensureInitialized()
            as BuildContext,
      );
      notifier.removeFromCart('1');
      expect(notifier.state.containsKey('1'), false);
    });

    test('updateQuantity updates quantity', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addToCart(
        '1',
        /* mock */ TestWidgetsFlutterBinding.ensureInitialized()
            as BuildContext,
      );
      notifier.updateQuantity('1', 5);
      expect(notifier.state['1'], 5);
    });

    test('updateQuantity removes if quantity <= 0', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addToCart(
        '1',
        /* mock */ TestWidgetsFlutterBinding.ensureInitialized()
            as BuildContext,
      );
      notifier.updateQuantity('1', 0);
      expect(notifier.state.containsKey('1'), false);
    });

    test('getTotal calculates correctly', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.state = {'1': 2, '2': 1};
      final products = [
        Product(
          id: '1',
          name: 'P1',
          presentPrice: 10.0,
          prevPrice: null,
          imageUrl: '',
          description: '',
        ),
        Product(
          id: '2',
          name: 'P2',
          presentPrice: 20.0,
          prevPrice: null,
          imageUrl: '',
          description: '',
        ),
      ];
      expect(notifier.getTotal(products), 40.0);
    });

    test('getTotal handles missing product', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.state = {'3': 1};
      final List<Product> products = [];
      expect(notifier.getTotal(products), 0.0);
    });

    test('clearCart empties cart', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addToCart(
        '1',
        /* mock */ TestWidgetsFlutterBinding.ensureInitialized()
            as BuildContext,
      );
      notifier.clearCart();
      expect(notifier.state, isEmpty);
    });

    test('persists cart to SharedPreferences', () async {
      final notifier = container.read(cartProvider.notifier);
      notifier.addToCart(
        '1',
        /* mock */ TestWidgetsFlutterBinding.ensureInitialized()
            as BuildContext,
      );
      final saved = prefs.getString('cart');
      expect(saved, jsonEncode({'1': 1}));
    });
  });
}
