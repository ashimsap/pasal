import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/address/application/address_providers.dart';
import 'package:pasal/src/features/categories/data/category_model.dart';

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('categories').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
  });
});

