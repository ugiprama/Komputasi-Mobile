import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanController {
  final supabase = Supabase.instance.client;

  // Tambah laporan baru
  Future<void> tambahLaporan({
    required String userId,
    required String judul,
    required String kategori,
    String? deskripsi,
    String? alamat,
    double? koordinatLat,
    double? koordinatLng,
    List<String>? fotoUrls,
    DateTime? waktuKejadian,
  }) async {
    try {
      await supabase.from('laporan').insert({
        'user_id': userId,
        'judul': judul,
        'kategori': kategori,
        'deskripsi': deskripsi,
        'alamat': alamat,
        'koordinat_lat': koordinatLat,
        'koordinat_lng': koordinatLng,
        'foto_urls': fotoUrls ?? [],
        'waktu_kejadian': waktuKejadian?.toUtc().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw Exception('Gagal menambahkan laporan: ${e.message}');
    }
  }

  // Ambil laporan berdasarkan user
  Future<List<Map<String, dynamic>>> laporanUser(String userId) async {
    try {
      final response = await supabase
          .from('laporan')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil laporan: ${e.message}');
    }
  }

  // Ambil semua laporan (untuk admin)
  Future<List<Map<String, dynamic>>> semuaLaporan() async {
    try {
      final response = await supabase
          .from('laporan')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil semua laporan: ${e.message}');
    }
  }

  // Update status laporan
  Future<void> updateStatus(String laporanId, String statusBaru) async {
    try {
      await supabase
          .from('laporan')
          .update({'status': statusBaru})
          .eq('id', laporanId);
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui status: ${e.message}');
    }
  }

  // Hapus laporan
  Future<void> hapusLaporan(String laporanId) async {
    try {
      await supabase.from('laporan').delete().eq('id', laporanId);
    } on PostgrestException catch (e) {
      throw Exception('Gagal menghapus laporan: ${e.message}');
    }
  }
}
