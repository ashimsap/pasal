import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/cart/application/cart_providers.dart';
import 'package:pasal/src/features/checkout/presentation/checkout_screen.dart';
import 'package:pasal/src/features/products/data/product_model.dart';
import 'package:pasal/src/features/reviews/presentation/reviews_section.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  final bool isFromCart;

  const ProductDetailScreen({super.key, required this.product, this.isFromCart = false});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentPage = 0;
  bool _justAddedToCart = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color borderColor = isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.5,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0), // Reduce bottom padding
                  child: Container(
                     decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: (widget.product.imageUrls.isNotEmpty)
                          ? PageView.builder(
                              itemCount: widget.product.imageUrls.length,
                              onPageChanged: (value) => setState(() => _currentPage = value),
                              itemBuilder: (context, index) {
                                return Image.network(
                                  widget.product.imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
                                );
                              },
                            )
                          : Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image_not_supported))),
                    ),
                  ),
                ),
              ),
            ),
            leading: Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
              ),
            ),
          ),
           if (widget.product.imageUrls.length > 1)
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0), // Reduced top padding
                  child: _buildDotsIndicator(widget.product.imageUrls.length, _currentPage, context),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 24.0), // Keep a reasonable top padding for the content
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProductInfoSection(context),
                const SizedBox(height: 24),
                ReviewsSection(product: widget.product),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionButtons(context, ref),
    );
  }

  Widget _buildDotsIndicator(int count, int currentIndex, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color tint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
             color: tint,
             borderRadius: BorderRadius.circular(12)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Take up only needed space
            children: List.generate(count, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: currentIndex == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: currentIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
          ),
        ),
      ),
    );

  }

  Widget _buildProductInfoSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _buildFrostedCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(label: Text(widget.product.category), backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
          const SizedBox(height: 8),
          Text(
            widget.product.name,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFrostedCard(
            context,
            fullWidth: false, // Set to false to make the card wrap its content
            child: Text(
              'NPR ${widget.product.price.toStringAsFixed(2)}',
              style: textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(widget.product.description),
        ],
      ),
    );
  }

  Widget _buildFrostedCard(BuildContext context, {required Widget child, bool fullWidth = true}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color tint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
    final Color borderColor = isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: fullWidth ? double.infinity : null,
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

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsProvider);
    final isActuallyInCart = cartItems.when(
      data: (items) => items.any((item) => item.productId == widget.product.id),
      loading: () => widget.isFromCart, 
      error: (_, __) => widget.isFromCart,
    );

    Widget mainButton;

    if (_justAddedToCart) {
      mainButton = OutlinedButton.icon(
        icon: const Icon(Icons.check),
        label: const Text('ADDED TO CART'),
        onPressed: null, // Disabled
        style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            disabledForegroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
      );
    } else if (isActuallyInCart) {
      mainButton = OutlinedButton.icon(
        icon: const Icon(Icons.remove_shopping_cart_outlined),
        label: const Text('REMOVE'),
        onPressed: () {
          ref.read(cartRepositoryProvider).removeFromCart(widget.product.id);
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
      );
    } else {
      mainButton = OutlinedButton.icon(
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('ADD TO CART'),
        onPressed: () {
          ref.read(cartRepositoryProvider).addToCart(widget.product);
          setState(() {
            _justAddedToCart = true;
          });
        },
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: mainButton),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('BUY NOW'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                );
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
