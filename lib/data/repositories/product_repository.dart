import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/products.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts(int page, int pageSize);
  Future<void> cacheProducts(List<Product> products);
  int getTotalProducts();
}

class ProductRepositoryImpl implements ProductRepository {
  final SharedPreferences prefs;
  static const int _totalProducts = 85;
  static const String _cacheKey = 'products';

  ProductRepositoryImpl(this.prefs);

  @override
  Future<List<Product>> getProducts(int page, int pageSize) async {
    final cachedJson = prefs.getString(_cacheKey);
    if (cachedJson != null) {
      final List<dynamic> jsonList = json.decode(cachedJson);
      final allProducts = jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
      final start = (page - 1) * pageSize;
      final end = start + pageSize > allProducts.length
          ? allProducts.length
          : start + pageSize;
      return allProducts.sublist(start, end);
    }

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (DateTime.now().second % 2 == 0) {
        throw http.ClientException('Mock network error');
      }

      // Loading From Assets(Mock Api)
      final jsonString = await rootBundle.loadString(
        'assets/mock/products.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final allProducts = jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
      final start = (page - 1) * pageSize;
      final end = start + pageSize > allProducts.length
          ? allProducts.length
          : start + pageSize;
      final pageProducts = allProducts.sublist(start, end);

      await cacheProducts(allProducts); // Cache all products
      return pageProducts;
    } on http.ClientException {
      rethrow;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    await prefs.setString(
      _cacheKey,
      jsonEncode(products.map((p) => p.toJson()).toList()),
    );
  }

  @override
  int getTotalProducts() => _totalProducts;
}
