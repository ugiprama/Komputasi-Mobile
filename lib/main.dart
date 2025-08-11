// Import yang tidak dipakai sudah dihapus agar bersih
import 'package:applaporwarga/views/auth/login_page.dart';
import 'package:applaporwarga/views/auth/role_selection_page.dart'; // Import RoleSelectionPage
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
      // Ubah home ke RoleSelectionPage sebagai halaman awal
      home: const RoleSelectionPage(),
      
      // Tambahkan routes untuk navigasi
      routes: {
        '/role-selection': (context) => const RoleSelectionPage(),
        '/user-auth': (context) => const LoginPage(), // Login untuk user/warga
        '/admin-login': (context) => const LoginPage(), // Nanti bisa diganti dengan AdminLoginPage
      },
      
      // Optional: Handle route yang tidak ditemukan
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const RoleSelectionPage(),
        );
      },
    );
  }
}