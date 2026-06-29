import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/place_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/feed_widgets.dart';
import '../home/place_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.firestoreService});

  final FirestoreService firestoreService;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedCategory = 0;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  static const _hcmcCenter = LatLng(10.7769, 106.7009);

  String get _categoryFilter =>
      AppConstants.mapCategories[_selectedCategory];

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlaceModel>>(
      stream: widget.firestoreService.watchPlaces(
        category: _categoryFilter == 'Tất cả' ? null : _categoryFilter,
      ),
      builder: (context, snapshot) {
        final places = snapshot.data ?? [];

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _hcmcCenter,
                initialZoom: 14,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.checkingo',
                ),
                MarkerLayer(
                  markers: places.map((place) {
                    return Marker(
                      point: LatLng(place.latitude, place.longitude),
                      width: 56,
                      height: 76,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailScreen(
                                place: place,
                                firestoreService: widget.firestoreService,
                              ),
                            ),
                          );
                        },
                        child: _MapMarker(place: place),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            SafeArea(
              child: Column(children: [_buildSearchAndFilters()]),
            ),
            _buildFloatingButtons(),
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.32,
              minChildSize: 0.15,
              maxChildSize: 0.75,
              builder: (context, scrollController) {
                return _buildBottomSheet(scrollController, places);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppTheme.cardShadow],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Tìm địa điểm gần bạn...',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search_rounded, color: AppColors.primary),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.mapCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [AppTheme.softShadow],
                    ),
                    child: Text(
                      AppConstants.mapCategories[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).size.height * 0.36,
      child: Column(
        children: [
          _MapFab(icon: Icons.my_location_rounded, onTap: () {}),
          const SizedBox(height: 12),
          _MapFab(icon: Icons.navigation_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(
    ScrollController scrollController,
    List<PlaceModel> places,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        'Địa điểm gần bạn',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text(
                        '${places.length} địa điểm',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (places.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.map_outlined,
                title: 'Chưa có địa điểm',
                subtitle: 'Thêm địa điểm mới từ nút + ở thanh điều hướng',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => PlaceListTile(
                    place: places[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaceDetailScreen(
                            place: places[index],
                            firestoreService: widget.firestoreService,
                          ),
                        ),
                      );
                    },
                  ),
                  childCount: places.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.place});

  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [AppTheme.cardShadow],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedImage(
                      imageUrl: place.imageUrl,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  if (place.rating > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.star.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 9, color: AppColors.star),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          CustomPaint(size: const Size(10, 6), painter: _PinTailPainter()),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapFab extends StatelessWidget {
  const _MapFab({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
      ),
    );
  }
}
