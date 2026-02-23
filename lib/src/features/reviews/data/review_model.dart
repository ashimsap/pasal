import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String name;
  final String title;
  final String content;
  final double rating;

  Review({
    required this.id,
    required this.name,
    required this.title,
    required this.content,
    required this.rating,
  });

  // fromMap for reading from Firestore
  factory Review.fromMap(Map<String, dynamic> map, String documentId) {
    return Review(
      id: documentId,
      name: map['name'] as String? ?? 'Anonymous',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      // Handle rating being a string or a number from the initial data
      rating: (map['rating'] is String)
          ? (double.tryParse(map['rating']) ?? 0.0)
          : (map['rating'] as num? ?? 0).toDouble(),
    );
  }

  // toMap for writing to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'content': content,
      'rating': rating,
      // Adding a server timestamp for sorting new reviews
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
