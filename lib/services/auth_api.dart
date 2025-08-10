import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthApi {
  final _client = SupabaseService.client;

  Future<AuthResponse> register(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
}
