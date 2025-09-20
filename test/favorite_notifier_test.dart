// test/favorites_notifier_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shop/main.dart';
import 'package:my_shop/provider/favourites_provider.dart';
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

  group('FavoritesNotifier', () {
    test('initial state is empty', () {
      final notifier = container.read(favoritesProvider.notifier);
      expect(notifier.state, isEmpty);
    });

    test('toggle adds if not favorite', () {
      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('1');
      expect(notifier.state.contains('1'), true);
    });

    test('toggle removes if favorite', () {
      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('1');
      notifier.toggle('1');
      expect(notifier.state.contains('1'), false);
    });

    test('isFavorite returns true if favorite', () {
      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('1');
      expect(notifier.isFavorite('1'), true);
    });

    test('isFavorite returns false if not favorite', () {
      final notifier = container.read(favoritesProvider.notifier);
      expect(notifier.isFavorite('1'), false);
    });

    test('count returns correct number', () {
      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('1');
      notifier.toggle('2');
      expect(notifier.count, 2);
    });

    test('favoritesList returns list', () {
      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('1');
      expect(notifier.favoritesList, ['1']);
    });

    test('persists favorites to SharedPreferences', () async {
      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('1');
      final saved = prefs.getStringList('favorites');
      expect(saved, ['1']);
    });
  });
}
