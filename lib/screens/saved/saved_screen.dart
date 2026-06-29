import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/place_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/feed_widgets.dart';
import '../home/place_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, required this.firestoreService});

  final FirestoreService firestoreService;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Vui lòng đăng nhập'));
    }

    return StreamBuilder<List<PlaceModel>>(
      stream: firestoreService.watchSavedPlaces(userId),
      builder: (context, snapshot) {
        final places = snapshot.data ?? [];
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đã lưu',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoading
                          ? 'Đang tải...'
                          : '${places.length} địa điểm đã lưu',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [AppTheme.softShadow],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm trong danh sách đã lưu...',
                          prefixIcon: Icon(Icons.search_rounded,
                              color: AppColors.textHint),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (places.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Chưa lưu địa điểm nào',
                  subtitle:
                      'Nhấn nút Lưu trên bài viết hoặc địa điểm để lưu lại',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _SavedPlaceCard(
                          place: places[index],
                          firestoreService: firestoreService,
                        ),
                    childCount: places.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SavedPlaceCard extends StatelessWidget {
  const _SavedPlaceCard({required this.place, required this.firestoreService});

  final PlaceModel place;
  final FirestoreService firestoreService;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaceDetailScreen(
              place: place,
              firestoreService: firestoreService,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppTheme.softShadow],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CachedImage(
                imageUrl: place.imageUrl,
                height: 160,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [AppTheme.softShadow],
                  ),
                  child: const Icon(Icons.bookmark_rounded,
                      color: AppColors.primary, size: 20),
                ),
              ),
              if (place.category.isNotEmpty)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      place.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (place.rating > 0) ...[
                      RatingBadge(rating: place.rating),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '${place.reviewCount} đánh giá',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 14, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.district,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),);
  }
}
