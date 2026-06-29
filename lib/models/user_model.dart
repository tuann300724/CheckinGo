import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    this.bio = '',
    this.location = 'Hồ Chí Minh',
    this.level = 1,
    this.isVerified = false,
    this.postCount = 0,
    this.followers = 0,
    this.following = 0,
    this.checkInCount = 0,
  });

  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final String bio;
  final String location;
  final int level;
  final bool isVerified;
  final int postCount;
  final int followers;
  final int following;
  final int checkInCount;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Người dùng',
      username: data['username'] as String? ?? '@user',
      avatarUrl: data['avatarUrl'] as String? ?? AppConstants.defaultAvatar,
      bio: data['bio'] as String? ?? '',
      location: data['location'] as String? ?? 'Hồ Chí Minh',
      level: (data['level'] as num?)?.toInt() ?? 1,
      isVerified: data['isVerified'] as bool? ?? false,
      postCount: (data['postCount'] as num?)?.toInt() ?? 0,
      followers: (data['followers'] as num?)?.toInt() ?? 0,
      following: (data['following'] as num?)?.toInt() ?? 0,
      checkInCount: (data['checkInCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'location': location,
      'level': level,
      'isVerified': isVerified,
      'postCount': postCount,
      'followers': followers,
      'following': following,
      'checkInCount': checkInCount,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
