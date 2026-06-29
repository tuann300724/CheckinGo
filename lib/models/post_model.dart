import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { review, checkin, photo }

class PostModel {
  const PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.userLevel,
    required this.placeId,
    required this.placeName,
    required this.rating,
    required this.content,
    required this.imageUrls,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.type,
    this.likedBy = const [],
    this.userIsVerified = false,
  });

  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final int userLevel;
  final bool userIsVerified;
  final String placeId;
  final String placeName;
  final double rating;
  final String content;
  final List<String> imageUrls;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final PostType type;
  final List<String> likedBy;

  bool isLikedBy(String userId) => likedBy.contains(userId);

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PostModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userAvatar: data['userAvatar'] as String? ?? '',
      userLevel: (data['userLevel'] as num?)?.toInt() ?? 1,
      userIsVerified: data['userIsVerified'] as bool? ?? false,
      placeId: data['placeId'] as String? ?? '',
      placeName: data['placeName'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      content: data['content'] as String? ?? '',
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      comments: (data['comments'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: _parseType(data['type'] as String?),
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
    );
  }

  static PostType _parseType(String? value) {
    return switch (value) {
      'checkin' => PostType.checkin,
      'photo' => PostType.photo,
      _ => PostType.review,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'userLevel': userLevel,
      'userIsVerified': userIsVerified,
      'placeId': placeId,
      'placeName': placeName,
      'rating': rating,
      'content': content,
      'imageUrls': imageUrls,
      'likes': likes,
      'comments': comments,
      'type': type.name,
      'likedBy': likedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
