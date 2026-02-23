import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasal/src/features/reviews/data/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepository(this._firestore);

  Future<void> submitReview(String productId, Review review) async {
    try {
      // Correctly point to the sub-collection for the given product
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .add(review.toMap());

      // After submitting a review, update the average rating of the product.
      final productRef = _firestore.collection('products').doc(productId);

      return _firestore.runTransaction((transaction) async {
        // Get all reviews for the product to calculate the new average
        final reviewsSnapshot = await _firestore
            .collection('products')
            .doc(productId)
            .collection('reviews')
            .get();

        if (reviewsSnapshot.docs.isNotEmpty) {
            final ratings = reviewsSnapshot.docs
                .map((doc) => (doc.data()['rating'] as num).toDouble())
                .toList();

            final double newAverageRating = ratings.reduce((a, b) => a + b) / ratings.length;
            final int newRatingCount = ratings.length;

            // Update the product document with the new average and count
            transaction.update(productRef, {
              'rating.rate': newAverageRating,
              'rating.count': newRatingCount,
            });
        }
      });
    } catch (e) {
      // Handle potential errors
      print('Error submitting review and updating product rating: $e');
      rethrow;
    }
  }
}
