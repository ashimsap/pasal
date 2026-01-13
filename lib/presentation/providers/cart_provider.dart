import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pasal/domain/models/cart_item.dart';
import 'package:pasal/domain/repositories/cart_repository.dart';
import 'package:pasal/presentation/providers/auth_provider.dart';

part 'cart_provider.freezed.dart';

@freezed
class CartState with _$CartState {
  const factory CartState({
    @Default([]) List<CartItem> items,
    @Default(AsyncValue.data(null)) AsyncValue<void> request,
  }) = _CartState;

  const CartState._();

  double get totalPrice =>
      items.fold(0, (total, item) => total + (item.price * item.quantity));
}

class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _cartRepository;
  final Ref _ref;

  CartNotifier(this._cartRepository, this._ref) : super(const CartState());

  Future<void> getCart() async {
    final isAuthenticated = _ref.read(authProvider).maybeWhen(
          authenticated: (_) => true,
          orElse: () => false,
        );

    if (!isAuthenticated) {
      state = state.copyWith(items: [], request: const AsyncValue.data(null));
      return;
    }

    state = state.copyWith(request: const AsyncValue.loading());
    try {
      final items = await _cartRepository.getCart();
      state = state.copyWith(items: items, request: const AsyncValue.data(null));
    } catch (e, st) {
      state = state.copyWith(request: AsyncValue.error(e, st));
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    state = state.copyWith(request: const AsyncValue.loading());
    try {
      await _cartRepository.addToCart(productId, quantity);
      await getCart();
    } catch (e, st) {
      state = state.copyWith(request: AsyncValue.error(e, st));
    }
  }

  Future<void> updateCart(String itemId, int quantity) async {
    state = state.copyWith(request: const AsyncValue.loading());
    try {
      await _cartRepository.updateCart(itemId, quantity);
      await getCart();
    } catch (e, st) {
      state = state.copyWith(request: AsyncValue.error(e, st));
    }
  }

  Future<void> removeFromCart(String itemId) async {
    state = state.copyWith(request: const AsyncValue.loading());
    try {
      await _cartRepository.removeFromCart(itemId);
      await getCart();
    } catch (e, st) {
      state = state.copyWith(request: AsyncValue.error(e, st));
    }
  }

  Future<void> checkout() async {
    state = state.copyWith(request: const AsyncValue.loading());
    try {
      await _cartRepository.checkout();
      state = state.copyWith(items: [], request: const AsyncValue.data(null));
    } catch (e, st) {
      state = state.copyWith(request: AsyncValue.error(e, st));
    }
  }

  void clearCart() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final cartRepository = ref.watch(cartRepositoryProvider);
  return CartNotifier(cartRepository, ref);
});
