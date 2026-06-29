import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/feed_widgets.dart';

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.tabIndex,
  });

  final IconData icon;
  final String label;
  final int tabIndex;
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.firestoreService});

  final FirestoreService firestoreService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  static const _quickActions = [
    _QuickAction(icon: Icons.article_outlined, label: 'Bài viết', tabIndex: 0),
    _QuickAction(
        icon: Icons.rate_review_outlined, label: 'Đánh giá', tabIndex: 1),
    _QuickAction(
        icon: Icons.location_on_rounded, label: 'Check-in', tabIndex: 2),
  ];

  Future<void> _signOut() async {
    await AuthService().signOut();
  }

  void _goToTab(int index) {
    setState(() => _selectedTab = index);
  }

  List<PostModel> _filterPosts(List<PostModel> posts) {
    return switch (_selectedTab) {
      1 => posts.where((p) => p.type == PostType.review).toList(),
      2 => posts.where((p) => p.type == PostType.checkin).toList(),
      _ => posts,
    };
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Vui lòng đăng nhập'));
    }

    return StreamBuilder<List<PostModel>>(
      stream: widget.firestoreService.watchUserPosts(userId),
      builder: (context, postsSnapshot) {
        final allPosts = postsSnapshot.data ?? [];
        final filteredPosts = _filterPosts(allPosts);
        final postsLoading =
            postsSnapshot.connectionState == ConnectionState.waiting &&
                !postsSnapshot.hasData;

        return StreamBuilder<UserModel?>(
          stream: widget.firestoreService.watchUser(userId),
          builder: (context, userSnapshot) {
            final user = userSnapshot.data;
            final userLoading =
                userSnapshot.connectionState == ConnectionState.waiting &&
                    user == null;

            if (userLoading && postsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProfileHeader(user),
                      _buildStats(allPosts),
                      _buildPremiumCard(),
                      _buildQuickActions(),
                    ],
                  ),
                ),
                if (postsLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (filteredPosts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: switch (_selectedTab) {
                        1 => Icons.rate_review_outlined,
                        2 => Icons.location_on_outlined,
                        _ => Icons.post_add_outlined,
                      },
                      title: switch (_selectedTab) {
                        1 => 'Chưa có đánh giá nào',
                        2 => 'Chưa có check-in nào',
                        _ => 'Chưa có bài viết nào',
                      },
                      subtitle: switch (_selectedTab) {
                        1 =>
                          'Nhấn nút + để viết đánh giá địa điểm bạn yêu thích',
                        2 =>
                          'Check-in tại địa điểm để ghi lại hành trình của bạn',
                        _ =>
                          'Nhấn nút + ở giữa để đăng bài viết đầu tiên',
                      },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ReviewCard(
                          post: filteredPosts[index],
                          firestoreService: widget.firestoreService,
                        ),
                        childCount: filteredPosts.length,
                      ),
                    ),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Đăng xuất',
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CachedImage(
                  imageUrl: user?.avatarUrl ?? AppConstants.defaultAvatar,
                  width: 96,
                  height: 96,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  user?.name ?? 'Người dùng',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (user?.isVerified == true) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded,
                    size: 20, color: AppColors.primary),
              ],
              const SizedBox(width: 8),
              LevelBadge(level: user?.level ?? 1),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            user?.username ?? '@user',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (user?.bio.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                user!.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.primary.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text(
                user?.location ?? 'Hồ Chí Minh',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<PostModel> posts) {
    final reviewCount = posts.where((p) => p.type == PostType.review).length;
    final checkInCount = posts.where((p) => p.type == PostType.checkin).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            value: '${posts.length}',
            label: 'Bài viết',
            onTap: () => _goToTab(0),
          ),
          const _StatDivider(),
          _StatItem(
            value: '$reviewCount',
            label: 'Đánh giá',
            onTap: () => _goToTab(1),
          ),
          const _StatDivider(),
          _StatItem(
            value: '$checkInCount',
            label: 'Check-in',
            onTap: () => _goToTab(2),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.diamond_rounded, color: Colors.white, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CheckinGo Premium',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Trải nghiệm không giới hạn, ưu đãi độc quyền',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: _quickActions.map((action) {
          final isActive = _selectedTab == action.tabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => _goToTab(action.tabIndex),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: isActive
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Icon(
                      action.icon,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color:
                          isActive ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.border);
  }
}
