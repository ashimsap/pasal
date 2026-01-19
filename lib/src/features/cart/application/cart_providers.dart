import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/address/application/address_providers.dart';
import 'package:pasal/src/features/auth/application/providers.dart';
import 'package:pasal/src/features/cart/data/cart_item_model.dart';
import 'package:pasal/src/features/cart/data/cart_repository.dart';

// Provider for the CartRepository
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(ref.watch(firestoreProvider), ref.watch(firebaseAuthProvider));
});

// StreamProvider to get the list of cart items for the current user
final cartItemsProvider = StreamProvider<List<CartItem>>((ref) {
  final cartRepository = ref.watch(cartRepositoryProvider);
  return cartRepository.watchCart();
});

// Manages the set of selected product IDs
final selectedCartItemIdsProvider = StateProvider<Set<String>>((ref) => {});

// NEW: Manages whether the cart is in selection mode
final isCartInSelectionModeProvider = StateProvider<bool>((ref) => false);

// Calculates the subtotal of the *selected* items in the cart
final cartSubtotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartItemsProvider).asData?.value ?? [];
  final selectedIds = ref.watch(selectedCartItemIdsProvider);

  if (selectedIds.isEmpty) return 0.0;

  final selectedItems = cartItems.where((item) => selectedIds.contains(item.productId)).toList();
  return selectedItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
});

// Checks if all items are selected
final allCartItemsSelectedProvider = Provider<bool>((ref) {
  final cartItems = ref.watch(cartItemsProvider).asData?.value ?? [];
  final selectedIds = ref.watch(selectedCartItemIdsProvider);
  
  if (cartItems.isEmpty) return false;
  
  return cartItems.length == selectedIds.length;
});
