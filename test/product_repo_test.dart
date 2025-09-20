import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:my_shop/data/repositories/product_repository.dart';
import 'package:my_shop/models/products.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  late ProductRepositoryImpl repository;
  late MockSharedPreferences mockPrefs;
  late MockAssetBundle mockBundle;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockBundle = MockAssetBundle();
    repository = ProductRepositoryImpl(mockPrefs, bundle: mockBundle);
  });

  group('ProductRepositoryImpl', () {
    const cacheKey = 'products';
    final mockProductJson = [
      {
        'id': '1',
        'name': 'Test Product',
        'imageUrl': 'test.jpg',
        'presentPrice': 100.0,
        'prevPrice': 120.0,
      },
    ];
    final mockProducts = mockProductJson
        .map((json) => Product.fromJson(json))
        .toList();

    group('getProducts', () {
      test('should return cached products if available', () async {
        // Arrange
        when(
          () => mockPrefs.getString(cacheKey),
        ).thenReturn(jsonEncode(mockProductJson));

        // Act
        final result = await repository.getProducts(1, 10);

        // Assert
        expect(result, equals(mockProducts));
        verify(() => mockPrefs.getString(cacheKey)).called(1);
        verifyNever(() => mockBundle.loadString(any()));
      });

      test('should fetch from assets and cache when no cached data', () async {
        // Arrange
        when(() => mockPrefs.getString(cacheKey)).thenReturn(null);
        when(
          () => mockBundle.loadString('assets/mock/products.json'),
        ).thenAnswer((_) async => jsonEncode(mockProductJson));
        when(
          () => mockPrefs.setString(cacheKey, any()),
        ).thenAnswer((_) async => true);

        // Act
        final result = await repository.getProducts(1, 10);

        // Assert
        expect(result, equals(mockProducts));
        verify(() => mockPrefs.getString(cacheKey)).called(1);
        verify(
          () => mockBundle.loadString('assets/mock/products.json'),
        ).called(1);
        verify(
          () => mockPrefs.setString(cacheKey, jsonEncode(mockProductJson)),
        ).called(1);
      });

      test('should handle pagination correctly', () async {
        // Arrange
        final largerProductList = List.generate(
          15,
          (index) => {
            'id': '$index',
            'name': 'Product $index',
            'imageUrl': 'test$index.jpg',
            'presentPrice': 100.0 + index,
            'prevPrice': 120.0 + index,
          },
        );
        when(
          () => mockPrefs.getString(cacheKey),
        ).thenReturn(jsonEncode(largerProductList));

        // Act
        final result = await repository.getProducts(2, 10);

        // Assert
        expect(result.length, equals(5)); // Only 5 items from index 10-14
        expect(result.first.id, equals('10')); // First item of second page
      });

      test('should throw ClientException on mock network error', () async {
        // Arrange
        when(() => mockPrefs.getString(cacheKey)).thenReturn(null);
        when(
          () => mockBundle.loadString('assets/mock/products.json'),
        ).thenThrow(http.ClientException('Mock network error'));

        // Act & Assert
        expect(
          () => repository.getProducts(1, 10),
          throwsA(isA<http.ClientException>()),
        );
      });

      test('should return empty list on other errors', () async {
        // Arrange
        when(() => mockPrefs.getString(cacheKey)).thenReturn(null);
        when(
          () => mockBundle.loadString('assets/mock/products.json'),
        ).thenThrow(Exception('Generic error'));

        // Act
        final result = await repository.getProducts(1, 10);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('cacheProducts', () {
      test('should cache products successfully', () async {
        // Arrange
        when(
          () => mockPrefs.setString(cacheKey, any()),
        ).thenAnswer((_) async => true);

        // Act
        await repository.cacheProducts(mockProducts);

        // Assert
        verify(
          () => mockPrefs.setString(cacheKey, jsonEncode(mockProductJson)),
        ).called(1);
      });
    });

    group('getTotalProducts', () {
      test('should return correct total products count', () {
        // Act
        final total = repository.getTotalProducts();

        // Assert
        expect(total, equals(85));
      });
    });
  });
}
