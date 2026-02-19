import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/cart/application/cart_providers.dart';
import 'package:pasal/src/features/cart/data/cart_item_model.dart';
import 'package:pasal/src/features/checkout/presentation/checkout_screen.dart';
import 'package:pasal/src/features/products/data/product_model.dart';
import 'package:pasal/src/features/products/presentation/product_detail_screen.dart';
import 'package:pasal/src/features/products/application/product_providers.dart'; // Needed to fetch product for detail screen

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  void _handleItemInteraction(BuildContext context, WidgetRef ref, CartItem item) {
    final isInSelectionMode = ref.read(isCartInSelectionModeProvider);
    if (isInSelectionMode) {
      _toggleSelection(ref, item.productId);
    } else {
      _navigateToDetail(context, ref, item.productId);
    }
  }

  void _toggleSelection(WidgetRef ref, String productId) {
    final selectedIdsNotifier = ref.read(selectedCartItemIdsProvider.notifier);
    final currentSelectedIds = selectedIdsNotifier.state;
    if (currentSelectedIds.contains(productId)) {
      selectedIdsNotifier.state = currentSelectedIds.where((id) => id != productId).toSet();
    } else {
      selectedIdsNotifier.state = {...currentSelectedIds, productId};
    }

    if (ref.read(selectedCartItemIdsProvider).isEmpty) {
      ref.read(isCartInSelectionModeProvider.notifier).state = false;
    }
  }

  void _enterSelectionMode(WidgetRef ref, String productId) {
    ref.read(isCartInSelectionModeProvider.notifier).state = true;
    ref.read(selectedCartItemIdsProvider.notifier).state = {productId};
  }
  
  void _navigateToDetail(BuildContext context, WidgetRef ref, String productId) {
      final allProducts = ref.read(productsStreamProvider).asData?.value ?? [];
      Product? product;
      for (final p in allProducts) {
        if (p.id == productId) {
          product = p;
          break;
        }
      }
      if (product != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product!, isFromCart: true)),
        );
      }
  }


  void _deleteSelected(WidgetRef ref) {
    final selectedIds = ref.read(selectedCartItemIdsProvider);
    if (selectedIds.isNotEmpty) {
      ref.read(cartRepositoryProvider).removeSelectedFromCart(selectedIds);
      ref.read(selectedCartItemIdsProvider.notifier).state = {};
      ref.read(isCartInSelectionModeProvider.notifier).state = false;
    }
  }

  void _selectAll(WidgetRef ref, List<CartItem> items) {
    ref.read(selectedCartItemIdsProvider.notifier).state = items.map((item) => item.productId).toSet();
  }

  void _deselectAll(WidgetRef ref) {
     ref.read(selectedCartItemIdsProvider.notifier).state = {};
     ref.read(isCartInSelectionModeProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemsAsync = ref.watch(cartItemsProvider);
    final selectedIds = ref.watch(selectedCartItemIdsProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final isInSelectionMode = ref.watch(isCartInSelectionModeProvider);

    return Column(
      children: [
        if (isInSelectionMode)
          _buildSelectionAppBar(context, ref, cartItemsAsync.asData?.value ?? []),
        
        Expanded(
          child: cartItemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('Your cart is empty.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = selectedIds.contains(item.productId);
                  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                  final titleColor = isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;
                  final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;

                  final Color unselectedTint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
                  final Color selectedTint = isDarkMode ? AppColors.darkFrostedTint.withOpacity(0.5) : AppColors.lightFrostedTint.withOpacity(0.4);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? selectedTint : unselectedTint,
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                                color: isSelected 
                                  ? Theme.of(context).colorScheme.primary 
                                  : (isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder),
                                width: isSelected ? 2 : 1.5,
                              ),
                          ),
                          child: ListTile(
                            onTap: () => _handleItemInteraction(context, ref, item),
                            onLongPress: () => _enterSelectionMode(ref, item.productId),
                            leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                                  ),
                            title: Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, color: titleColor)),
                            subtitle: Text('NPR ${item.price.toStringAsFixed(2)}', style: TextStyle(color: subtitleColor)),
                            trailing: isSelected
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        iconSize: 20,
                                        onPressed: item.quantity > 1
                                            ? () => ref.read(cartRepositoryProvider).updateQuantity(item.productId, item.quantity - 1)
                                            : null, // Disable if quantity is 1
                                      ),
                                      Text(item.quantity.toString(), style: TextStyle(fontSize: 16, color: titleColor)),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        iconSize: 20,
                                        onPressed: () => ref.read(cartRepositoryProvider).updateQuantity(item.productId, item.quantity + 1),
                                      ),
                                    ],
                                  )
                                : null, // Show nothing if not selected
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
        _buildBottomBar(context, subtotal, selectedIds.isNotEmpty),
      ], 
    );
  }
  
  Widget _buildSelectionAppBar(BuildContext context, WidgetRef ref, List<CartItem> items) {
    final allSelected = ref.watch(allCartItemsSelectedProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color tint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
    final Color borderColor = isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          height: kToolbarHeight + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            color: tint,
            border: Border(bottom: BorderSide(color: borderColor, width: 1.5))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _deselectAll(ref),
                  ),
                  Text(
                    '${ref.watch(selectedCartItemIdsProvider).length} selected',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => allSelected ? _deselectAll(ref) : _selectAll(ref, items),
                    child: Text(allSelected ? 'Deselect All' : 'Select All')
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _deleteSelected(ref),
                  )
                ]
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, double subtotal, bool isAnyItemSelected) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color tint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
    final Color borderColor = isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: tint,
            border: Border(top: BorderSide(color: borderColor, width: 1.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subtotal', style: TextStyle(color: secondaryTextColor)),
                  Text('NPR ${subtotal.toStringAsFixed(2)}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primaryTextColor)),
                ],
              ),
              ElevatedButton(
                onPressed: isAnyItemSelected ? () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: isAnyItemSelected ? theme.colorScheme.primary : null,
                  foregroundColor: isAnyItemSelected ? theme.colorScheme.onPrimary : null,
                ),
                child: const Text('CHECKOUT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
