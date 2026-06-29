import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final ImagePicker _picker = ImagePicker();

  // Điền thông tin cấu hình Cloudinary của bạn ở đây
  final String _cloudName = "dr93uw1b7"; 
  final String _uploadPreset = "checkingo_preset";

  /// Chọn nhiều ảnh từ thư viện
  Future<List<XFile>> pickImages({int maxImages = 5}) async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    return images.take(maxImages).toList();
  }

  /// Chọn 1 ảnh từ thư viện
  Future<XFile?> pickSingleImage() async {
    return _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  }

  /// Hàm core xử lý việc upload single file lên Cloudinary qua REST API
  Future<String?> _uploadToCloudinary(XFile file) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: path.basename(file.path),
        ));
      }

      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonDecoded = jsonDecode(responseData);
        return jsonDecoded['secure_url'] as String; // Trả về link https của ảnh
      } else {
        print('Cloudinary Upload Error Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Cloudinary Upload Exception: $e');
      return null;
    }
  }

  /// Upload danh sách ảnh của bài post lên Cloudinary
  Future<List<String>> uploadPostImages({
    required String userId, // Giữ lại tham số để không bị lỗi compile ở màn hình gọi hàm
    required List<XFile> files,
  }) async {
    final urls = <String>[];

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final imageUrl = await _uploadToCloudinary(file);
      
      if (imageUrl != null) {
        urls.add(imageUrl);
      }
    }

    return urls;
  }

  /// Upload 1 ảnh của địa điểm lên Cloudinary
  Future<String> uploadPlaceImage({
    required String userId, // Giữ lại tham số để tránh lỗi compile ở code cũ
    required XFile file,
  }) async {
    final imageUrl = await _uploadToCloudinary(file);
    
    if (imageUrl != null) {
      return imageUrl;
    } else {
      throw Exception("Upload ảnh địa điểm lên Cloudinary thất bại.");
    }
  }
}