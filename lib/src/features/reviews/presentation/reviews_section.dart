import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/products/data/product_model.dart';
import 'package:pasal/src/features/reviews/application/review_providers.dart';
import 'package:pasal/src/features/reviews/data/review_model.dart';

// 1. StateProvider to manage the expanded state of the reviews
final reviewsExpandedProvider = StateProvider<bool>((ref) => false);

class ReviewsSection extends ConsumerWidget {
  final Product product;
  const ReviewsSection({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsStreamProvider(product.id));
    final isExpanded = ref.watch(reviewsExpandedProvider);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        reviewsAsync.when(
          data: (reviews) {
            double averageRating = reviews.isNotEmpty
                ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length
                : 0.0;
            return _buildFrostedCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Reviews (${reviews.length})', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      // 2. "See All" / "See Less" button
                      if (reviews.length > 1)
                        TextButton(
                          onPressed: () => ref.read(reviewsExpandedProvider.notifier).state = !isExpanded,
                          child: Text(isExpanded ? 'See Less' : 'See All'),
                        ),
                    ],
                  ),
                  if (reviews.isNotEmpty) ...[
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
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading reviews: $err'),
        ),
        const SizedBox(height: 16),
        // 3. Conditionally display reviews based on the expanded state
        reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) return const Center(child: Text('No reviews yet.'));

            final reviewsToShow = isExpanded ? reviews : (reviews.isNotEmpty ? [reviews.first] : []);

            return Column(
              children: reviewsToShow.map((review) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildReviewItem(context, review),
              )).toList(),
            );
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

  Widget _buildReviewItem(BuildContext context, Review review) {
    return _buildFrostedCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person), radius: 15),
              const SizedBox(width: 8),
              Text(review.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) => Icon(Icons.star, color: index < review.rating ? Colors.amber : Colors.grey, size: 16)),
          ),
          const SizedBox(height: 8),
          if (review.title.isNotEmpty) ...[
            Text(review.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
          ],
          Text(review.content),
        ],
      ),
    );
  }
}
