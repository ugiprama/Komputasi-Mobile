// Import yang tidak dipakai sudah dihapus agar bersih
import 'package:applaporwarga/views/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:applaporwarga/services/exp_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final supabaseService = SupabaseService();
  await supabaseService.init();               
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lapor Warga',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
