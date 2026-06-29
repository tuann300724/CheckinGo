import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/place_model.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({
    super.key,
    required this.firestoreService,
    required this.storageService,
    this.initialType = PostType.review,
    this.initialPlace,
  });

  final FirestoreService firestoreService;
  final StorageService storageService;
  final PostType initialType;
  final PlaceModel? initialPlace;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  PostType _type = PostType.review;
  double _rating = 4.0;
  PlaceModel? _selectedPlace;
  String? _selectedPlaceId;
  List<PlaceModel> _places = [];
  List<XFile> _images = [];
  bool _isLoading = false;
  bool _loadingPlaces = true;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    if (widget.initialPlace != null) {
      _selectedPlace = widget.initialPlace;
      _selectedPlaceId = widget.initialPlace!.id;
    }
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    widget.firestoreService.watchPlaces().first.then((places) {
      if (mounted) {
        setState(() {
          _places = places;
          _loadingPlaces = false;
          if (_selectedPlaceId != null && !_places.any((p) => p.id == _selectedPlaceId)) {
            _places.insert(0, _selectedPlace!);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await widget.storageService.pickImages();
    if (images.isNotEmpty) {
      setState(() => _images = [..._images, ...images].take(5).toList());
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa điểm')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profile =
          await widget.firestoreService.getUser(user.uid) ??
              UserModel(
                id: user.uid,
                name: user.displayName ?? 'Người dùng',
                username: '@user',
                avatarUrl: AppConstants.defaultAvatar,
              );

      final imageUrls = _images.isNotEmpty
          ? await widget.storageService.uploadPostImages(
              userId: user.uid,
              files: _images,
            )
          : <String>[];

      final post = PostModel(
        id: '',
        userId: user.uid,
        userName: profile.name,
        userAvatar: profile.avatarUrl,
        userLevel: profile.level,
        userIsVerified: profile.isVerified,
        placeId: _selectedPlace!.id,
        placeName: _selectedPlace!.name,
        rating: _type == PostType.review ? _rating : 0,
        content: _contentController.text.trim(),
        imageUrls: imageUrls,
        likes: 0,
        comments: 0,
        createdAt: DateTime.now(),
        type: _type,
      );

      await widget.firestoreService.createPost(post);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng bài thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo bài viết'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Đăng',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 20),
            _buildPlaceSelector(),
            if (_type == PostType.review) ...[
              const SizedBox(height: 20),
              _buildRatingSelector(),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Chia sẻ trải nghiệm của bạn...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập nội dung bài viết' : null,
            ),
            const SizedBox(height: 20),
            _buildImagePicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _TypeChip(
          label: 'Đánh giá',
          icon: Icons.rate_review_rounded,
          selected: _type == PostType.review,
          onTap: () => setState(() => _type = PostType.review),
        ),
        const SizedBox(width: 8),
        _TypeChip(
          label: 'Check-in',
          icon: Icons.location_on_rounded,
          selected: _type == PostType.checkin,
          onTap: () => setState(() => _type = PostType.checkin),
        ),
        const SizedBox(width: 8),
        _TypeChip(
          label: 'Đăng ảnh',
          icon: Icons.camera_alt_rounded,
          selected: _type == PostType.photo,
          onTap: () => setState(() => _type = PostType.photo),
        ),
      ],
    );
  }

  Widget _buildPlaceSelector() {
    if (_loadingPlaces) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_places.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Chưa có địa điểm nào. Hãy thêm địa điểm mới trước.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedPlaceId,
      decoration: InputDecoration(
        labelText: 'Chọn địa điểm',
        prefixIcon: const Icon(Icons.place_outlined, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: _places
          .map(
            (p) => DropdownMenuItem(
              value: p.id,
              child: Text(p.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (v) {
        setState(() {
          _selectedPlaceId = v;
          _selectedPlace = _places.firstWhere((p) => p.id == v);
        });
      },
      validator: (v) => v == null ? 'Chọn địa điểm' : null,
    );
  }

  Widget _buildRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đánh giá: ${_rating.toStringAsFixed(1)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Slider(
          value: _rating,
          min: 1,
          max: 5,
          divisions: 8,
          activeColor: AppColors.primary,
          label: _rating.toStringAsFixed(1),
          onChanged: (v) => setState(() => _rating = v),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ảnh (tối đa 5)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._images.asMap().entries.map((entry) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(
                            entry.value.path,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(entry.value.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _images.removeAt(entry.key)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (_images.length < 5)
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.add_photo_alternate_outlined,
                      color: AppColors.primary),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : AppColors.textSecondary, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
