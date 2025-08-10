// lib/services/storage_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _bucketName = 'laporanfoto'; // Pastikan bucket ini sudah dibuat di Supabase

  /// Upload file dan kembalikan URL publik
  Future<String> uploadFoto(File file) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';

      // Upload ke storage
      final uploadResponse = await _client.storage
          .from(_bucketName)
          .upload(fileName, file);

      // Kalau error saat upload
      if (uploadResponse.isEmpty) {
        throw Exception("Upload gagal: response kosong");
      }

      // Ambil URL publik
      final publicUrl = _client.storage.from(_bucketName).getPublicUrl(fileName);

      return publicUrl;
    } on StorageException catch (e) {
      throw Exception("Storage error: ${e.message}");
    } catch (e) {
      throw Exception("Error umum saat upload foto: $e");
    }
  }
}
