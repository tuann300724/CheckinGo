import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/place_model.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _places =>
      _db.collection('places');
  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');

  // ── Users ──────────────────────────────────────────────

  Future<UserModel?> getUser(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUser(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.id).set({
      ...user.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> incrementPostCount(String userId) async {
    await _users.doc(userId).update({
      'postCount': FieldValue.increment(1),
    });
  }

  // ── Places ─────────────────────────────────────────────

  Stream<List<PlaceModel>> watchPlaces({String? category}) {
    return _places.orderBy('reviewCount', descending: true).snapshots().map(
      (snapshot) {
        var places = snapshot.docs.map(PlaceModel.fromFirestore).toList();
        if (category != null && category != 'Tất cả') {
          places = places.where((p) => p.category == category).toList();
        }
        return places;
      },
    );
  }

  Stream<List<PlaceModel>> watchTrendingPlaces({int limit = 10}) {
    return _places
        .orderBy('reviewCount', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(PlaceModel.fromFirestore).toList(),
        );
  }

  Future<String> createPlace(PlaceModel place) async {
    final doc = await _places.add(place.toFirestore());
    return doc.id;
  }

  Future<PlaceModel?> getPlace(String placeId) async {
    if (placeId.isEmpty) return null;
    final doc = await _places.doc(placeId).get();
    if (!doc.exists) return null;
    return PlaceModel.fromFirestore(doc);
  }

  Future<void> updatePlaceRating(String placeId, double newRating) async {
    final doc = await _places.doc(placeId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final currentRating = (data['rating'] as num?)?.toDouble() ?? 0;
    final reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
    final updatedRating =
        ((currentRating * reviewCount) + newRating) / (reviewCount + 1);

    await _places.doc(placeId).update({
      'rating': double.parse(updatedRating.toStringAsFixed(1)),
      'reviewCount': reviewCount + 1,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Posts ──────────────────────────────────────────────

  Stream<List<PostModel>> watchPosts({PostType? type, String? placeId}) {
    if (placeId != null) {
      // Lọc theo placeId và sắp xếp trên bộ nhớ để tránh phải tạo Composite Index trên Firestore
      return _posts.where('placeId', isEqualTo: placeId).snapshots().map((snapshot) {
        final posts = snapshot.docs.map(PostModel.fromFirestore).toList();
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return posts;
      });
    }

    Query<Map<String, dynamic>> query =
        _posts.orderBy('createdAt', descending: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs.map(PostModel.fromFirestore).toList(),
        );
  }

  Stream<List<PostModel>> watchUserPosts(String userId) {
    return _posts.where('userId', isEqualTo: userId).snapshots().map(
      (snapshot) {
        final posts = snapshot.docs.map(PostModel.fromFirestore).toList();
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return posts;
      },
    );
  }

  Future<void> createPost(PostModel post) async {
    await _posts.add(post.toFirestore());
    await incrementPostCount(post.userId);

    if (post.placeId.isNotEmpty && post.rating > 0) {
      await updatePlaceRating(post.placeId, post.rating);
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    final docRef = _posts.doc(postId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
      final likes = (data['likes'] as num?)?.toInt() ?? 0;

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        transaction.update(docRef, {
          'likedBy': likedBy,
          'likes': likes > 0 ? likes - 1 : 0,
        });
      } else {
        likedBy.add(userId);
        transaction.update(docRef, {
          'likedBy': likedBy,
          'likes': likes + 1,
        });
      }
    });
  }

  // ── Saved places ───────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _savedRef(String userId) =>
      _users.doc(userId).collection('saved_places');

  Stream<List<PlaceModel>> watchSavedPlaces(String userId) {
    return _savedRef(userId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final places = <PlaceModel>[];
      for (final savedDoc in snapshot.docs) {
        final placeId = savedDoc.data()['placeId'] as String? ?? savedDoc.id;
        final placeDoc = await _places.doc(placeId).get();
        if (placeDoc.exists) {
          places.add(PlaceModel.fromFirestore(placeDoc));
        }
      }
      return places;
    });
  }

  Future<bool> isPlaceSaved(String userId, String placeId) async {
    final doc = await _savedRef(userId).doc(placeId).get();
    return doc.exists;
  }

  Future<void> toggleSavePlace(String userId, PlaceModel place) async {
    final ref = _savedRef(userId).doc(place.id);
    final doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'placeId': place.id,
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Seed sample data (chạy 1 lần khi DB trống) ────────

  Future<bool> seedSampleDataIfEmpty() async {
    final placesSnapshot = await _places.limit(1).get();
    if (placesSnapshot.docs.isNotEmpty) return false;

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'system';

    final samplePlaces = [
      PlaceModel(
        id: '',
        name: 'The Workshop Coffee',
        imageUrl:
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
        rating: 4.8,
        reviewCount: 324,
        district: 'Quận 1',
        category: 'Cà phê',
        latitude: 10.7720,
        longitude: 106.6983,
        createdBy: userId,
      ),
      PlaceModel(
        id: '',
        name: 'Bánh Mì Huỳnh Hoa',
        imageUrl:
            'https://images.unsplash.com/photo-1551782450-a2132b4ba21d?w=400',
        rating: 4.9,
        reviewCount: 892,
        district: 'Quận 1',
        category: 'Ăn uống',
        latitude: 10.7690,
        longitude: 106.6910,
        createdBy: userId,
      ),
      PlaceModel(
        id: '',
        name: 'Landmark 81',
        imageUrl:
            'https://images.unsplash.com/photo-1583417319070-4a3bc80845e1?w=400',
        rating: 4.7,
        reviewCount: 567,
        district: 'Bình Thạnh',
        category: 'Vui chơi',
        latitude: 10.7950,
        longitude: 106.7220,
        createdBy: userId,
      ),
    ];

    for (final place in samplePlaces) {
      await _places.add(place.toFirestore());
    }

    return true;
  }
}
