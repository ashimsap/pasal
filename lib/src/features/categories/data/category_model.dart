import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String title;
  final Map<String, List<String>> filters;

  Category({required this.title, required this.filters});

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final filtersMap = <String, List<String>>{};

    if (data['filters'] is Map) {
      (data['filters'] as Map).forEach((key, value) {
        if (value is Map && value['filterList'] is List) {
          filtersMap[key] = List<String>.from(value['filterList'] as List);
        }
      });
    }

    return Category(
      title: data['title'] as String? ?? 'Unnamed Category',
      filters: filtersMap,
    );
  }
}
