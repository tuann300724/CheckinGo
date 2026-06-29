import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
    _progressController.forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const _BackgroundDecorations(),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        const CheckinGoLogo(size: 110),
                        const SizedBox(height: 24),
                        const BrandTitle(fontSize: 38),
                        const SizedBox(height: 12),
                        Text(
                          'Đi để trải nghiệm, ăn để nhớ!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary.withValues(alpha: 0.9),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                const _FoodIllustration(),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value,
                                minHeight: 4,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Khám phá những địa điểm tuyệt vời quanh bạn...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SplashBackgroundPainter(),
      size: Size.infinite,
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);

    // Soft clouds
    final cloudPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.4;
      canvas.drawCircle(Offset(x, y), 40 + random.nextDouble() * 30, cloudPaint);
      canvas.drawCircle(
          Offset(x + 30, y - 10), 30 + random.nextDouble() * 20, cloudPaint);
    }

    // Dotted route lines
    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6;
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }

    // Location pins scattered
    final pinPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08);

    for (var i = 0; i < 8; i++) {
      final x = 20 + random.nextDouble() * (size.width - 40);
      final y = 60 + random.nextDouble() * (size.height * 0.35);
      _drawPin(canvas, Offset(x, y), 12, pinPaint);
    }

    // HCMC skyline silhouette
    final skylinePaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final skylinePath = Path();
    final baseY = size.height * 0.55;
    skylinePath.moveTo(0, baseY);

    final buildings = [
      (0.0, 0.08, 0.12),
      (0.08, 0.06, 0.18),
      (0.14, 0.04, 0.10),
      (0.18, 0.10, 0.25),
      (0.28, 0.05, 0.14),
      (0.33, 0.08, 0.20),
      (0.41, 0.03, 0.08),
      (0.44, 0.12, 0.30),
      (0.56, 0.06, 0.16),
      (0.62, 0.04, 0.10),
      (0.66, 0.09, 0.22),
      (0.75, 0.05, 0.14),
      (0.80, 0.07, 0.18),
      (0.87, 0.04, 0.12),
      (0.91, 0.06, 0.15),
    ];

    for (final (start, width, height) in buildings) {
      final x = size.width * start;
      final w = size.width * width;
      final h = size.height * height;
      skylinePath.addRect(Rect.fromLTWH(x, baseY - h, w, h));
    }

    skylinePath.lineTo(size.width, baseY);
    skylinePath.close();
    canvas.drawPath(skylinePath, skylinePaint);
  }

  void _drawPin(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size);
    path.quadraticBezierTo(
      center.dx - size * 0.5,
      center.dy,
      center.dx,
      center.dy - size * 0.8,
    );
    path.quadraticBezierTo(
      center.dx + size * 0.5,
      center.dy,
      center.dx,
      center.dy + size,
    );
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(center.dx, center.dy - size * 0.3),
      size * 0.35,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FoodIllustration extends StatelessWidget {
  const _FoodIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 280,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FoodItem(
                emoji: '☕',
                label: 'Cà phê',
                color: const Color(0xFF8B4513),
              ),
              const SizedBox(width: 16),
              _FoodItem(
                emoji: '🥖',
                label: 'Bánh mì',
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              _FoodItem(
                emoji: '🍜',
                label: 'Phở',
                color: const Color(0xFFE67E22),
              ),
              const SizedBox(width: 16),
              _FoodItem(
                emoji: '🌿',
                label: '',
                color: const Color(0xFF27AE60),
                isPlant: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FoodItem extends StatelessWidget {
  const _FoodItem({
    required this.emoji,
    required this.label,
    required this.color,
    this.isPlant = false,
  });

  final String emoji;
  final String label;
  final Color color;
  final bool isPlant;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isPlant ? 48 : 56,
          height: isPlant ? 48 : 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: isPlant ? 24 : 28)),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
