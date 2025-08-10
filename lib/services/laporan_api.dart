import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/laporan.dart';

class LaporanApi {
  final supabase = Supabase.instance.client;

  Future<void> createLaporan(Laporan laporan) async {
    final response = await supabase.from('laporan').insert(laporan.toMap());
    if (response.error != null) {
      throw response.error!.message;
    }
  }

  Future<List<Laporan>> getLaporanByUser(String userId) async {
    final response = await supabase
        .from('laporan')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => Laporan.fromMap(map))
        .toList();
  }
}
