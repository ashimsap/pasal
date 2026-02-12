import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/products/application/product_providers.dart';
import 'package:pasal/src/features/reviews/data/review_model.dart';

// This provider is a "family" because it takes an argument (the productId)
// It will create a separate stream for each product's reviews.
final reviewsStreamProvider = StreamProvider.autoDispose.family<List<Review>, String>((ref, productId) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.watchReviews(productId).map((snapshot) {
    return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
  });
});

