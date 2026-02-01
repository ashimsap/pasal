import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String name;
  final String title;
  final String content;
  final double rating;

  Review({
    required this.name,
    required this.title,
    required this.content,
    required this.rating,
  });

  // Updated factory to handle the structure from your JSON
  factory Review.fromMap(Map<String, dynamic> data) {
    return Review(
      name: data['name'] as String? ?? 'Anonymous',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      // The rating in reviews can be a String or a number, so we handle both
      rating: (data['rating'] is String)
          ? (double.tryParse(data['rating']!) ?? 0.0)
          : (data['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Review(
      name: data['name'] as String? ?? 'Anonymous',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
