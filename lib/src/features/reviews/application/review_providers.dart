import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/orders/application/order_providers.dart';
import 'package:pasal/src/features/products/data/product_model.dart';
import 'package:pasal/src/features/reviews/data/review_model.dart';
import 'package:pasal/src/features/reviews/data/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return ReviewRepository(firestore);
});


// A unified model for displaying any kind of review
class DisplayReview {
  final String userName;
  final String? userImageUrl;
  final double rating;
  final String comment;
  final String title;
  final DateTime timestamp;

  DisplayReview({
    required this.userName,
    this.userImageUrl,
    required this.rating,
    required this.comment,
    required this.title,
    required this.timestamp,
  });
}

// NEW provider to combine initial JSON reviews and Firestore reviews
final combinedReviewsProvider =
    StreamProvider.autoDispose.family<List<DisplayReview>, Product>((ref, product) {

  // 1. Get initial reviews from the product model
  final initialReviews = product.reviews.map((ir) {
    return DisplayReview(
      userName: ir.name,
      userImageUrl: null,
      rating: ir.rating,
      comment: ir.content,
      title: ir.title,
      timestamp: DateTime.fromMicrosecondsSinceEpoch(0), // Old timestamp to sort them last
    );
  }).toList();

  // 2. Get firestore reviews stream
  final firestore = ref.read(firebaseFirestoreProvider);
  final firestoreStream = firestore
      .collection('reviews')
      .where('productId', isEqualTo: product.id)
      .snapshots();

  // 3. Map the stream to merge with initial reviews
  return firestoreStream.map((snapshot) {
    final firestoreReviews = snapshot.docs.map((doc) {
      final review = Review.fromMap(doc.data(), doc.id);
      return DisplayReview(
        userName: review.userName,
        userImageUrl: review.userImageUrl,
        rating: review.rating,
        comment: review.comment,
        title: '', // User-submitted reviews don't have a title field
        timestamp: review.timestamp,
      );
    }).toList();

    // 4. Combine, sort, and return (newest first)
    final allReviews = [...firestoreReviews, ...initialReviews];
    allReviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allReviews;
  });
});
