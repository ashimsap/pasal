import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/orders/application/order_providers.dart';
import 'package:pasal/src/features/reviews/data/review_model.dart';
import 'package:pasal/src/features/reviews/data/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return ReviewRepository(firestore);
});

final reviewsStreamProvider = StreamProvider.autoDispose.family<List<Review>, String>((ref, productId) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  // Correctly points to the sub-collection
  return firestore
      .collection('products')
      .doc(productId)
      .collection('reviews')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Review.fromMap(doc.data(), doc.id)).toList());
});
