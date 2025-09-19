import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/products.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<void> cacheProducts(List<Product> products);
}

class ProductRepositoryImpl implements ProductRepository {
  final SharedPreferences prefs;

  ProductRepositoryImpl(this.prefs);

  @override
  Future<List<Product>> getProducts() async {
    // Try cache first for offline startup
    final cachedJson = prefs.getString('products');
    if (cachedJson != null) {
      final List<dynamic> jsonList = json.decode(cachedJson);
      return jsonList.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    }

    try {
      // Simulate network call with delay/error chance
      await Future.delayed(const Duration(seconds: 1));
      if (DateTime.now().second % 2 == 0) {
        throw http.ClientException('Mock network error');
      }

      // Load from assets (mock API)
      final jsonString = await rootBundle.loadString('assets/mock/products.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final products = jsonList.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();

      await cacheProducts(products);
      return products;
    } on http.ClientException {
      rethrow;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    await prefs.setString('products', jsonEncode(products.map((p) => p.toJson()).toList()));
  }
}