import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/products/data/product_model.dart';
import 'package:pasal/src/features/products/presentation/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color tint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
    final Color borderColor = isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                    child: (product.imageUrls.isNotEmpty)
                        ? Image.network(
                            product.imageUrls[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                          )
                        : Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image_not_supported))),
                  ),
                ),
                // Product Details
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(product.rating.rate.toString(), style: textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'NPR ${product.price.toStringAsFixed(2)}',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




