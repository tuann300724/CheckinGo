import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../create/create_place_screen.dart';
import '../create/create_post_screen.dart';
import '../home/home_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../saved/saved_screen.dart';
import '../../models/post_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.firestoreService});

  final FirestoreService firestoreService;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
  }

  void _onCreateTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CreatePostSheet(
        onReview: () => _openCreatePost(PostType.review),
        onCheckIn: () => _openCreatePost(PostType.checkin),
        onAddPlace: _openCreatePlace,
        onPhoto: () => _openCreatePost(PostType.photo),
      ),
    );
  }

  void _openCreatePost(PostType type) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          firestoreService: widget.firestoreService,
          storageService: _storageService,
          initialType: type,
        ),
      ),
    );
  }

  void _openCreatePlace() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePlaceScreen(
          firestoreService: widget.firestoreService,
          storageService: _storageService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(firestoreService: widget.firestoreService),
      MapScreen(firestoreService: widget.firestoreService),
      SavedScreen(firestoreService: widget.firestoreService),
      ProfileScreen(firestoreService: widget.firestoreService),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onCreateTap: _onCreateTap,
      ),
    );
  }
}

class _CreatePostSheet extends StatelessWidget {
  const _CreatePostSheet({
    required this.onReview,
    required this.onCheckIn,
    required this.onAddPlace,
    required this.onPhoto,
  });

  final VoidCallback onReview;
  final VoidCallback onCheckIn;
  final VoidCallback onAddPlace;
  final VoidCallback onPhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tạo bài viết mới',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          _CreateOption(
            icon: Icons.rate_review_rounded,
            title: 'Viết đánh giá',
            subtitle: 'Chia sẻ trải nghiệm tại địa điểm',
            color: const Color(0xFFFF6B1A),
            onTap: onReview,
          ),
          const SizedBox(height: 12),
          _CreateOption(
            icon: Icons.location_on_rounded,
            title: 'Check-in',
            subtitle: 'Ghi lại vị trí bạn đang ghé thăm',
            color: const Color(0xFF10B981),
            onTap: onCheckIn,
          ),
          const SizedBox(height: 12),
          _CreateOption(
            icon: Icons.add_location_alt_rounded,
            title: 'Thêm địa điểm mới',
            subtitle: 'Tạo địa điểm chưa có trên bản đồ',
            color: const Color(0xFF6366F1),
            onTap: onAddPlace,
          ),
          const SizedBox(height: 12),
          _CreateOption(
            icon: Icons.camera_alt_rounded,
            title: 'Đăng ảnh',
            subtitle: 'Chia sẻ khoảnh khắc ẩm thực & du lịch',
            color: const Color(0xFFEC4899),
            onTap: onPhoto,
          ),
        ],
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
