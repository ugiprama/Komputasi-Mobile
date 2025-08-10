import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_api.dart';
import '../services/supabase_service.dart';

class AuthController {
  final AuthApi _authApi = AuthApi();
  final _client = SupabaseService.client;

  Future<void> registerUser(String email, String password, String name) async {
    final res = await _authApi.register(email, password);

    final id = res.user?.id;
    if (id == null) {
      throw Exception("Registrasi gagal. ID user tidak ditemukan.");
    }

    final insertRes = await _client.from('profiles').insert({
      'id': id,
      'name': name,
    });

    if (insertRes.error != null) {
      throw insertRes.error!;
    }
  }

  Future<void> loginUser(String email, String password) async {
    final res = await _authApi.login(email, password);
    // bisa arahkan ke halaman Home setelah berhasil login
  }

  Future<void> logoutUser() async {
    await _authApi.logout();
  }
}
