import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';  // For sharedPreferencesProvider

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(ref.watch(sharedPreferencesProvider)),
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences prefs;

  FavoritesNotifier(this.prefs) : super(Set<String>.from(prefs.getStringList('favorites') ?? []));

  void toggle(String id) {
    final newFavorites = Set<String>.from(state);
    if (newFavorites.contains(id)) {
      newFavorites.remove(id);
    } else {
      newFavorites.add(id);
    }
    state = newFavorites;
    prefs.setStringList('favorites', newFavorites.toList());
  }

  bool isFavorite(String id) => state.contains(id);
}