import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasal/src/features/products/data/rating_model.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final List<String> imageUrls;
  final String description;
  final String category;
  final Rating rating; // This is the correct field

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrls,
    required this.description,
    required this.category,
    required this.rating, // Restored this field
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      id: doc.id,
      // Checking for both 'name' and 'title' to be safe, as your data has both
      name: data['name'] ?? data['title'] ?? 'Unnamed Product',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      // Checking for both 'imageUrls' and 'imgs' to be safe
      imageUrls: List<String>.from(data['imageUrls'] ?? data['imgs'] ?? []),
      description: data['description'] ?? data['specs']?.toString() ?? 'No description available.',
      category: data['category'] as String? ?? 'Uncategorized',
      // This correctly parses the rating object from your data
      rating: data['rating'] != null ? Rating.fromJson(data['rating']) : Rating(rate: 0, count: 0),
    );
  }
}
