class Product {
  final String id;
  final String name;
  final double? prevPrice;
  final double presentPrice;
  final String imageUrl;
  final String description;
  final String? review;
  final double? rating;
  final String? details;

  Product({
    required this.id,
    required this.name,
    this.prevPrice,
    required this.presentPrice,
    required this.imageUrl,
    required this.description,
    this.review,
    this.rating,
    this.details,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      prevPrice: (json['prevPrice'] as num?)?.toDouble(),
      presentPrice: (json['presentPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      review: json['review'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      details: json['details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prevPrice': prevPrice,
      'presentPrice': presentPrice,
      'imageUrl': imageUrl,
      'description': description,
      'review': review,
      'rating': rating,
      'details': details,
    };
  }
}
