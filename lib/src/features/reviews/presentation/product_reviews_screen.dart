import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/reviews/application/review_providers.dart';
import 'package:pasal/src/features/reviews/data/review_model.dart';

class ProductReviewsScreen extends ConsumerWidget {
  final String productId;
  const ProductReviewsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Correctly watch the provider with the productId
    final reviewsAsync = ref.watch(reviewsStreamProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reviews'),
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews yet for this product.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ReviewCard(review: review);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

// This card now correctly displays the fields from the Review model
class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // In a real app, you might fetch user data based on a userId on the review
                const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 15)),
                const SizedBox(width: 8),
                Text(review.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(Icons.star, color: index < review.rating ? Colors.amber : Colors.grey.shade300, size: 18);
              }),
            ),
            const SizedBox(height: 8),
            if (review.title.isNotEmpty) ...[
               Text(review.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
               const SizedBox(height: 4),
            ],
            if (review.content.isNotEmpty)
              Text(review.content),
          ],
        ),
      ),
    );
  }
}
