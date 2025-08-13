import 'package:supabase_flutter/supabase_flutter.dart';

class AdminServices {
  final supabase = Supabase.instance.client;

  Future<int> getTotalReports() async {
    try {
      final total = await supabase.rpc('get_laporan_total');
      return (total ?? 0) as int;
    } catch (e) {
      print("Error getTotalReports: $e");
      return 0;
    }
  }

  Future<int> getTotalVerifiedUsers() async {
    try {
      final total = await supabase.rpc('get_total_verified_users');
      return (total ?? 0) as int;
    } catch (e) {
      print("Error getTotalVerifiedUsers: $e");
      return 0;
    }
  }
}
