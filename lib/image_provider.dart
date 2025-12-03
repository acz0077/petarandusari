import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageProviderNotifier extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // Fungsi untuk memilih gambar dari galeri
  Future<XFile?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  // Fungsi untuk memilih gambar dari kamera
  Future<XFile?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    return image;
  }

  // Fungsi untuk upload gambar ke Supabase Storage
  Future<String?> uploadImage(
    XFile image, {
    String bucketName = 'images',
  }) async {
    try {
      // Buat path unik untuk gambar (misalnya berdasarkan timestamp)
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final String filePath = 'uploads/$fileName';

      // Upload file ke Supabase Storage
      final File file = File(image.path);
      await _supabase.storage.from(bucketName).upload(filePath, file);

      // Dapatkan URL publik gambar
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      notifyListeners(); // Notify listeners jika diperlukan
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan URL gambar dari path
  String getImageUrl(String path, {String bucketName = 'images'}) {
    return _supabase.storage.from(bucketName).getPublicUrl(path);
  }

  // Fungsi untuk menghapus gambar dari Supabase Storage
  Future<bool> deleteImage(String path, {String bucketName = 'images'}) async {
    try {
      await _supabase.storage.from(bucketName).remove([path]);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Fungsi untuk mendapatkan list file di bucket (opsional)
  Future<List<String>> listImages({String bucketName = 'images'}) async {
    try {
      final response = await _supabase.storage.from(bucketName).list();
      final List<String> fileNames = response.map((file) => file.name).toList();
      return fileNames;
    } catch (e) {
      print('Error listing images: $e');
      return [];
    }
  }
}
