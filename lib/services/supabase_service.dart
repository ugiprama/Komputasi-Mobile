import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://ihhhoaiwbzrrnflnsfro.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImloaGhvYWl3Ynpycm5mbG5zZnJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0NDcwNzEsImV4cCI6MjA3MDAyMzA3MX0.0aLoEVQ2c-8PqDgg40ndSRawgR7c0b0tQqq-hhv0K-Q',
    );
  }
}
