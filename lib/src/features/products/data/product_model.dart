import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasal/src/features/products/data/rating_model.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final List<String> imageUrls;
  final String description;
  final String category;
  final Rating rating;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrls,
    required this.description,
    required this.category,
    required this.rating,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Product',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      description: data['description'] ?? 'No description available.',
      category: data['category'] as String? ?? 'Uncategorized',
      rating: data['rating'] != null ? Rating.fromJson(data['rating']) : Rating(rate: 0, count: 0),
    );
  }
}
