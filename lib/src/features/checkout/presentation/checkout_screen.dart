import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'dart:ui';

import 'package:pasal/src/features/cart/application/cart_providers.dart';
import 'package:pasal/src/features/cart/data/cart_item_model.dart';
import 'package:pasal/src/features/address/data/address_model.dart';
import 'package:pasal/src/features/address/presentation/address_book_screen.dart';
import 'package:pasal/src/features/orders/application/order_providers.dart';
import 'package:pasal/src/features/orders/data/order_model.dart';
import 'package:pasal/src/features/settings/presentation/payment_methods_screen.dart';

import '../../auth/application/providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final List<CartItem>? items;
  const CheckoutScreen({super.key, this.items});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late List<CartItem> _itemsToCheckout;
  String _selectedPaymentMethod = 'Cash on Delivery';
  Address? _selectedAddress;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    // If items are passed directly (for Buy Now), use them.
    // Otherwise, this will be handled by the provider in the build method.
    _itemsToCheckout = widget.items ?? [];
  }

  double _getShippingCost(double subtotal) {
    return subtotal > 5000 ? 0.0 : 50.0; // Free shipping for orders over 5000
  }

  void _updateQuantity(String productId, int newQuantity) {
    setState(() {
      final itemIndex = _itemsToCheckout.indexWhere((item) => item.productId == productId);
      if (itemIndex != -1) {
        // For single-item checkout, allow changing quantity
        if (widget.items != null) {
           if (newQuantity > 0) {
            _itemsToCheckout[itemIndex] = _itemsToCheckout[itemIndex].copyWith(quantity: newQuantity);
           } else {
             // If qty is 0, you could remove it or prevent it.
             // For now, we'll just not let it go below 1 for a direct buy.
             _itemsToCheckout[itemIndex] = _itemsToCheckout[itemIndex].copyWith(quantity: 1);
           }
        } else {
          // For cart checkout, update through the repository
          ref.read(cartRepositoryProvider).updateQuantity(productId, newQuantity);
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final cartItemsAsync = ref.watch(cartItemsProvider);

    // Decide which list of items to use
    if (widget.items == null) {
      // Coming from cart, use the provider
      return Scaffold(
        appBar: _buildAppBar(),
        body: cartItemsAsync.when(
          data: (items) {
             _itemsToCheckout = items; // Update local list from provider
            if (items.isEmpty) {
              return const Center(
                  child: Text('Your cart is empty. Cannot proceed to checkout.'));
            }
            return _buildContent(context, _itemsToCheckout);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      );
    } else {
      // Coming from "Buy Now", use the items passed in the widget
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildContent(context, _itemsToCheckout),
      );
    }
  }

  AppBar _buildAppBar() {
      return AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
  }

  Widget _buildContent(BuildContext context, List<CartItem> items) {
    if (items.isEmpty) {
        return const Center(child: Text('No items to check out.'));
    }

    final subtotal = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final shippingCost = _getShippingCost(subtotal);
    final total = subtotal + shippingCost;

    return Stack(
      children: [
        Container(color: Theme.of(context).scaffoldBackgroundColor),
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildSectionCard(context, title: 'Order Summary', child: _buildOrderSummary(items)),
                    const SizedBox(height: 16),
                    _buildSectionCard(context, title: 'Shipping Address', child: _buildAddressSection()),
                    const SizedBox(height: 16),
                    _buildSectionCard(context, title: 'Payment Method', child: _buildPaymentMethodSection()),
                  ],
                ),
              ),
              _buildBottomBar(context, subtotal, shippingCost, total, items),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildFrostedCard(BuildContext context, {required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color tint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
    final Color borderColor = isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildFrostedCard(context, child: child),
      ],
    );
  }

  Widget _buildOrderSummary(List<CartItem> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('NPR ${item.price.toStringAsFixed(2)}'),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _updateQuantity(item.productId, item.quantity - 1),
                    iconSize: 20),
                Text(item.quantity.toString()),
                IconButton(
                    icon: const Icon(Icons.add),
                     onPressed: () => _updateQuantity(item.productId, item.quantity + 1),
                    iconSize: 20),
              ],
            )
          ],
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 24),
    );
  }

  Widget _buildAddressSection() {
    // ... (This widget remains the same as before)
     return _selectedAddress == null
        ? TextButton.icon(
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Select Shipping Address'),
            onPressed: () async {
              final Address? result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const AddressBookScreen(isSelectionMode: true),
                ),
              );
              if (result != null) {
                setState(() {
                  _selectedAddress = result;
                });
              }
            },
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedAddress!.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(_selectedAddress!.addressLine1),
                    Text(
                        '${_selectedAddress!.city}, ${_selectedAddress!.state} ${_selectedAddress!.postalCode}'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final Address? result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const AddressBookScreen(isSelectionMode: true),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _selectedAddress = result;
                    });
                  }
                },
                child: const Text('Change'),
              ),
            ],
          );
  }

  Widget _buildPaymentMethodSection() {
    // ... (This widget remains the same as before)
     return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Cash on Delivery'),
          value: 'Cash on Delivery',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
        ),
        if (_selectedPaymentMethod != 'Cash on Delivery')
          RadioListTile<String>(
            title: Text(_selectedPaymentMethod),
            value: _selectedPaymentMethod,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              // This is just for show, the main selection is done below
            },
          ),
        const Divider(),
        TextButton.icon(
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: const Text('Choose another way to pay'),
          onPressed: () async {
            final String? result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    const PaymentMethodsScreen(isSelectionMode: true),
              ),
            );
            if (result != null) {
              setState(() {
                _selectedPaymentMethod = result;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, double subtotal,
      double shippingCost, double total, List<CartItem> items) {
          final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryTextColor =
        isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    bool isCod = _selectedPaymentMethod == 'Cash on Delivery';

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(top: BorderSide(color: isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: TextStyle(color: secondaryTextColor)),
              Text('NPR ${subtotal.toStringAsFixed(2)}',
                  style: TextStyle(color: primaryTextColor)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping', style: TextStyle(color: secondaryTextColor)),
              Text('NPR ${shippingCost.toStringAsFixed(2)}',
                  style: TextStyle(color: primaryTextColor)),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, color: primaryTextColor)),
              Text('NPR ${total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, color: primaryTextColor)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessingPayment
                  ? null
                  : () async {
                      final userId = ref.read(authRepositoryProvider).currentUser?.uid;
                      if (userId == null || _selectedAddress == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a shipping address.')),
                        );
                        return;
                      }

                      if (!isCod) {
                        setState(() => _isProcessingPayment = true);
                        await Future.delayed(const Duration(seconds: 3));
                        setState(() => _isProcessingPayment = false);
                      }

                      final newOrder = Order(
                        id: ' ', // Firestore will generate this
                        userId: userId,
                        items: items,
                        shippingAddress: _selectedAddress!,
                        paymentMethod: _selectedPaymentMethod,
                        subtotal: subtotal,
                        shippingCost: shippingCost,
                        total: total,
                        orderDate: DateTime.now(),
                      );
                      await ref.read(orderRepositoryProvider).addOrder(newOrder);
                      
                      // Only clear the cart if we were checking out from the cart
                      if (widget.items == null) {
                        ref.read(cartRepositoryProvider).clearCart();
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order placed successfully!')),
                      );
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isProcessingPayment
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isCod ? 'Place Order' : 'Pay Now'),
            ),
          ),
        ],
      ),
    );
  }
}

extension CartItemCopy on CartItem {
  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      productName: productName,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}
