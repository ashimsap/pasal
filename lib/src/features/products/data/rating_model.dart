class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});

  // This factory can now handle both Maps and plain numbers from the JSON
  factory Rating.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return Rating(
        rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
        count: json['count'] as int? ?? 0,
      );
    } else if (json is num) {
      return Rating(rate: json.toDouble(), count: 0); // Assume 0 count if only a rate is provided
    } else if (json is String) {
      return Rating(rate: double.tryParse(json) ?? 0.0, count: 0);
    } else {
      return Rating(rate: 0.0, count: 0); // Default fallback
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'count': count,
    };
  }
}
