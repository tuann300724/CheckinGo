import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/place_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class CreatePlaceScreen extends StatefulWidget {
  const CreatePlaceScreen({
    super.key,
    required this.firestoreService,
    required this.storageService,
  });

  final FirestoreService firestoreService;
  final StorageService storageService;

  @override
  State<CreatePlaceScreen> createState() => _CreatePlaceScreenState();
}

class _CreatePlaceScreenState extends State<CreatePlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = AppConstants.placeCategories.first;
  XFile? _image;
  bool _isLoading = false;
  LatLng _selectedLocation = const LatLng(10.7769, 106.7009);
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await widget.storageService.pickSingleImage();
    if (image != null) setState(() => _image = image);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      var imageUrl =
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400';

      if (_image != null) {
        imageUrl = await widget.storageService.uploadPlaceImage(
          userId: user.uid,
          file: _image!,
        );
      }

      final place = PlaceModel(
        id: '',
        name: _nameController.text.trim(),
        imageUrl: imageUrl,
        rating: 0,
        reviewCount: 0,
        district: _districtController.text.trim(),
        category: _category,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        description: _descriptionController.text.trim(),
        createdBy: user.uid,
      );

      await widget.firestoreService.createPlace(place);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm địa điểm thành công!')),
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
        title: const Text('Thêm địa điểm mới'),
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
                    'Tạo',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  image: _image != null
                      ? DecorationImage(
                          image: kIsWeb
                              ? NetworkImage(_image!.path) as ImageProvider
                              : FileImage(File(_image!.path)) as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              size: 40, color: AppColors.primary),
                          SizedBox(height: 8),
                          Text('Thêm ảnh địa điểm'),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: _fieldDecoration('Tên địa điểm', Icons.store_outlined),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập tên địa điểm' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration:
                  _fieldDecoration('Danh mục', Icons.category_outlined),
              items: AppConstants.placeCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _districtController,
              decoration:
                  _fieldDecoration('Quận/Huyện', Icons.place_outlined),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập quận/huyện' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _fieldDecoration('Mô tả (tuỳ chọn)', Icons.notes),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn vị trí trên bản đồ',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              'Tọa độ đã chọn: ${_selectedLocation.latitude.toStringAsFixed(5)}, ${_selectedLocation.longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 14,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.checkingo',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
