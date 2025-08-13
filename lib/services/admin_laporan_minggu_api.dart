import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminLaporanApiMingguan {
  final supabase = Supabase.instance.client;

  /// Ambil jumlah laporan per hari selama 7 hari terakhir
  Future<List<Map<String, dynamic>>> getLaporanMingguan() async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 6));

    // Query ke supabase: ambil laporan dari 7 hari terakhir
    final response = await supabase
        .from('laporan')
        .select('created_at')
        .gte('created_at', startDate.toIso8601String());

    // Hitung jumlah laporan per tanggal
    Map<String, int> countPerDay = {};

    for (int i = 0; i < 7; i++) {
      final day = startDate.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(day);
      countPerDay[key] = 0;
    }

    for (var item in response) {
      final date = DateTime.parse(item['created_at']);
      final key = DateFormat('yyyy-MM-dd').format(date);
      if (countPerDay.containsKey(key)) {
        countPerDay[key] = countPerDay[key]! + 1;
      }
    }

    // Ubah map ke List terurut berdasarkan tanggal
    final result = countPerDay.entries
        .map((e) => {'tanggal': e.key, 'jumlah': e.value})
        .toList();

    return result;
  }
}
