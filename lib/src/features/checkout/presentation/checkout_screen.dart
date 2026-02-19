import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'dart:ui';

import 'package:pasal/src/features/cart/application/cart_providers.dart';
import 'package:pasal/src/features/cart/data/cart_item_model.dart';
import 'package:pasal/src/features/address/data/address_model.dart';
import 'package:pasal/src/features/address/presentation/address_book_screen.dart';
import 'package:pasal/src/features/settings/presentation/payment_methods_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedPaymentMethod;
  Address? _selectedAddress;

  double _getShippingCost(double subtotal) {
    return subtotal > 5000 ? 0.0 : 50.0; // Free shipping for orders over 5000
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cartItemsAsync = ref.watch(cartItemsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          // Content
          SafeArea(
            child: cartItemsAsync.when(
              data: (items) {
                final subtotal = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
                final shippingCost = _getShippingCost(subtotal);
                final total = subtotal + shippingCost;

                return Column(
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
                    _buildBottomBar(context, subtotal, shippingCost, total),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
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
                IconButton(icon: const Icon(Icons.remove), onPressed: () => ref.read(cartRepositoryProvider).updateQuantity(item.productId, item.quantity - 1), iconSize: 20,),
                Text(item.quantity.toString()),
                IconButton(icon: const Icon(Icons.add), onPressed: () => ref.read(cartRepositoryProvider).updateQuantity(item.productId, item.quantity + 1), iconSize: 20,),
              ],
            )
          ],
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 24),
    );
  }

  Widget _buildAddressSection() {
    return _selectedAddress == null
        ? TextButton.icon(
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Select Shipping Address'),
            onPressed: () async {
              final Address? result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddressBookScreen()),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedAddress!.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(_selectedAddress!.addressLine1),
                  Text('${_selectedAddress!.city}, ${_selectedAddress!.state} ${_selectedAddress!.postalCode}'),
                ],
              ),
              TextButton(
                onPressed: () async {
                  final Address? result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddressBookScreen()),
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
    return _selectedPaymentMethod == null
        ? TextButton.icon(
            icon: const Icon(Icons.payment_outlined),
            label: const Text('Select Payment Method'),
            onPressed: () async {
              final String? result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
              );
              if (result != null) {
                setState(() {
                  _selectedPaymentMethod = result;
                });
              }
            },
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_selectedPaymentMethod!, style: const TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () async {
                  final String? result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                  );
                  if (result != null) {
                    setState(() {
                      _selectedPaymentMethod = result;
                    });
                  }
                },
                child: const Text('Change'),
              ),
            ],
          );
  }

  Widget _buildBottomBar(BuildContext context, double subtotal, double shippingCost, double total) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
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
              Text('NPR ${subtotal.toStringAsFixed(2)}', style: TextStyle(color: primaryTextColor)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping', style: TextStyle(color: secondaryTextColor)),
              Text('NPR ${shippingCost.toStringAsFixed(2)}', style: TextStyle(color: primaryTextColor)),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primaryTextColor)),
              Text('NPR ${total.toStringAsFixed(2)}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primaryTextColor)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { /* TODO: Implement place order logic */ },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }
}
