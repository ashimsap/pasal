import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasal/src/features/products/data/product_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository(this._firestore);

  Stream<List<Product>> watchProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Stream<QuerySnapshot> watchReviews(String productId) {
    return _firestore.collection('products').doc(productId).collection('reviews').snapshots();
  }

  Future<void> seedDatabase() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final WriteBatch batch = _firestore.batch();

      // Seed Categories
      if (jsonData['categories'] is Map<String, dynamic>) {
        final categoriesData = jsonData['categories'] as Map<String, dynamic>;
        for (final categoryKey in categoriesData.keys) {
          final categoryData = categoriesData[categoryKey];
          if (categoryData is Map<String, dynamic>) {
            final categoryDocRef = _firestore.collection('categories').doc(categoryKey);
            batch.set(categoryDocRef, categoryData);
          }
        }
      }

      // Seed Products and their Reviews
      if (jsonData['products'] is List) {
        final productsData = jsonData['products'] as List<dynamic>;
        for (final productData in productsData) {
          // Trusting the cleaned JSON data
          final productId = productData['id'] as String;
          final productDocRef = _firestore.collection('products').doc(productId);

          final imageUrls = List<String>.from(productData['imgs'] as List);
          final description = (productData['specs'] as List).cast<String>().join('\n');
          final ratingValue = (productData['rating'] as num).toDouble();
          final priceAsDouble = (productData['price'] as num).toDouble();
          final reviewCount = (productData['reviews'] as List?)?.length ?? 0;

          batch.set(productDocRef, {
            'name': productData['title'] as String,
            'price': priceAsDouble,
            'imageUrls': imageUrls,
            'description': description,
            'category': productData['category'] as String,
            'rating': {
              'rate': ratingValue,
              'count': reviewCount,
            }
          });

          // Seed Reviews as a subcollection
          if (productData['reviews'] is List) {
            int reviewIndex = 0;
            for (final reviewData in productData['reviews']) {
              final reviewId = '${productId}_review_${reviewIndex++}';
              final reviewDocRef = productDocRef.collection('reviews').doc(reviewId);
              final reviewRatingAsDouble = (reviewData['rating'] as num).toDouble();

              batch.set(reviewDocRef, {
                'name': reviewData['name'] as String,
                'title': reviewData['title'] as String,
                'content': reviewData['content'] as String,
                'rating': reviewRatingAsDouble,
              });
            }
          }
        }
      }

      await batch.commit();
      debugPrint('Successfully seeded database!');
    } catch (e, stacktrace) {
      debugPrint('Error seeding database: $e\n$stacktrace');
      throw Exception('Failed to parse or seed database: $e');
    }
  }
}
