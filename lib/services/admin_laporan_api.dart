import 'package:supabase_flutter/supabase_flutter.dart';

class AdminLaporanApi {
  final supabase = Supabase.instance.client;

  Future<Map<String, int>> getStatCardsData() async {
    print('DEBUG: Ambil total laporan via RPC');
    final totalResult = await supabase.rpc('get_laporan_total');
    print('DEBUG: totalResult => ${totalResult.runtimeType}');
    print('DEBUG: totalResult: $totalResult');
    final total = totalResult as int;

    print('DEBUG: Ambil laporan per status via RPC');
    final perStatusResult = await supabase.rpc('get_laporan_stats');

    print('DEBUG: perStatusResult => $perStatusResult');

    int proses = 0;
    int pengerjaan = 0;
    int selesai = 0;

    for (final row in perStatusResult) {
      final status = (row['status'] as String).toLowerCase();
      final count = (row['count'] as int);
      if (status == 'proses') proses = count;
      else if (status == 'pengerjaan') pengerjaan = count;
      else if (status == 'selesai') selesai = count;
    }

    return {
      'total': total,
      'proses': proses,
      'pengerjaan': pengerjaan,
      'selesai': selesai,
    };
  }
}
