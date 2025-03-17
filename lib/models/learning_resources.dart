class LearningResource {
  final String title;
  final String url;
  final String type; // "course", "book", "tutorial", "documentation", etc.
  final double rating;
  final String platform;
  final bool isPaid;
  final String? price;
  final int estimatedHours;

  LearningResource({
    required this.title,
    required this.url,
    required this.type,
    required this.rating,
    required this.platform,
    required this.isPaid,
    this.price,
    required this.estimatedHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'type': type,
      'rating': rating,
      'platform': platform,
      'isPaid': isPaid,
      'price': price,
      'estimatedHours': estimatedHours,
    };
  }

  factory LearningResource.fromMap(Map<String, dynamic> map) {
    return LearningResource(
      title: map['title'] as String,
      url: map['url'] as String,
      type: map['type'] as String,
      rating: map['rating'] as double,
      platform: map['platform'] as String,
      isPaid: map['isPaid'] as bool,
      price: map['price'] as String?,
      estimatedHours: map['estimatedHours'] as int,
    );
  }
}
