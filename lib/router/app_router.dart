import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_shop/screens/cart_view.dart' show CartScreen;
import 'package:my_shop/screens/check_out_view.dart';
import 'package:my_shop/screens/product_details_view.dart';
import 'package:my_shop/screens/product_list_view.dart';
import 'package:my_shop/screens/success_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) =>
            ProductDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => const SuccessScreen(),
      ),
    ],
    redirect: (context, state) {
      if (state.uri.toString() == '/success' && state.fullPath == null) {
        return '/';
      }
      return null;
    },
  );
});

final router = Provider((ref) => ref.watch(routerProvider));
