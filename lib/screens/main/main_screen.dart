import 'package:flutter/material.dart';

import '../../widgets/bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../saved/saved_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    MapScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  void _onCreateTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _CreatePostSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: _screens[_currentIndex],
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
  const _CreatePostSheet();

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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          _CreateOption(
            icon: Icons.rate_review_rounded,
            title: 'Viết đánh giá',
            subtitle: 'Chia sẻ trải nghiệm tại địa điểm',
            color: const Color(0xFFFF6B1A),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          _CreateOption(
            icon: Icons.location_on_rounded,
            title: 'Check-in',
            subtitle: 'Ghi lại vị trí bạn đang ghé thăm',
            color: const Color(0xFF10B981),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          _CreateOption(
            icon: Icons.add_location_alt_rounded,
            title: 'Thêm địa điểm mới',
            subtitle: 'Tạo địa điểm chưa có trên bản đồ',
            color: const Color(0xFF6366F1),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          _CreateOption(
            icon: Icons.camera_alt_rounded,
            title: 'Đăng ảnh',
            subtitle: 'Chia sẻ khoảnh khắc ẩm thực & du lịch',
            color: const Color(0xFFEC4899),
            onTap: () => Navigator.pop(context),
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
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
