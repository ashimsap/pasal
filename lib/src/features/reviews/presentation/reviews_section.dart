import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/products/data/product_model.dart';
import 'package:pasal/src/features/reviews/application/review_providers.dart';
import 'package:pasal/src/features/reviews/data/review_model.dart';
import 'package:pasal/src/features/reviews/presentation/product_reviews_screen.dart';

class ReviewsSection extends ConsumerWidget {
  final Product product;
  const ReviewsSection({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This provider will now ONLY fetch user-submitted reviews from Firestore.
    final firestoreReviewsAsync = ref.watch(reviewsStreamProvider(product.id));
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER SECTION --- 
        // This section now uses the initial data from the product model 
        // and adds the count of new reviews from Firestore.
        _buildFrostedCard(
          context,
          child: firestoreReviewsAsync.when(
            data: (firestoreReviews) {
              // Combine the initial count with the new reviews count
              final totalReviewCount = product.rating.count + firestoreReviews.length;
              
              // Recalculate the average rating
              final totalRatingSum = (product.rating.rate * product.rating.count) + (firestoreReviews.isNotEmpty ? firestoreReviews.map((r) => r.rating).reduce((a, b) => a + b) : 0);
              final averageRating = totalReviewCount > 0 ? totalRatingSum / totalReviewCount : 0.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Reviews ($totalReviewCount)', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      if (totalReviewCount > 1)
                        TextButton(
                          onPressed: () {
                             Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProductReviewsScreen(productId: product.id),
                            ));
                          },
                          child: const Text('See All'),
                        ),
                    ],
                  ),
                  if (totalReviewCount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            IconData starIcon = Icons.star_border;
                            if (averageRating >= index + 1) {
                              starIcon = Icons.star;
                            } else if (averageRating >= index + 0.5) {
                              starIcon = Icons.star_half;
                            }
                            return Icon(starIcon, color: Colors.amber, size: 20);
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(averageRating.toStringAsFixed(1), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ]
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()), // Show a loader while fetching firestore reviews
            error: (err, stack) => Text('Error: $err'),
          ),
        ),
        const SizedBox(height: 16),

        // --- USER REVIEWS LIST --- 
        // This section now ONLY shows reviews from Firestore.
        firestoreReviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) return const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Be the first to review this product!'),
            ));

            // Always show the latest review first
            return ReviewCard(review: reviews.first);
          },
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => const SizedBox.shrink(),
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
}
