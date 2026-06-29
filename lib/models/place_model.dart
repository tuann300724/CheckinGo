import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  const PlaceModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.district,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.description = '',
    this.createdBy = '',
  });

  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String district;
  final String category;
  final double latitude;
  final double longitude;
  final String description;
  final String createdBy;

  factory PlaceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlaceModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      district: data['district'] as String? ?? '',
      category: data['category'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 10.7769,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 106.7009,
      description: data['description'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'district': district,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  PlaceModel copyWith({
    double? rating,
    int? reviewCount,
    String? imageUrl,
  }) {
    return PlaceModel(
      id: id,
      name: name,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      district: district,
      category: category,
      latitude: latitude,
      longitude: longitude,
      description: description,
      createdBy: createdBy,
    );
  }
}
