import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/address/application/address_providers.dart'; // For firestoreProvider
import 'package:pasal/src/features/products/data/product_model.dart';
import 'package:pasal/src/features/products/data/product_repository.dart';

// Provider for the ProductRepository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(firestoreProvider));
});

// StreamProvider to get all products
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.watchProducts();
});

// Provider that filters products based on a category string
final productsByCategoryProvider = Provider.autoDispose.family<List<Product>, String>((ref, category) {
  final allProducts = ref.watch(productsStreamProvider).asData?.value ?? [];
  if (category == 'All') {
    return allProducts;
  }
  return allProducts.where((product) => product.category == category).toList();
});
