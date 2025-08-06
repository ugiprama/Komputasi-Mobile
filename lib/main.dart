// Import yang tidak dipakai sudah dihapus agar bersih
import 'package:applaporwarga/views/auth/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lapor Warga',
      // Menghilangkan banner "DEBUG" di pojok kanan atas
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Menggunakan skema warna baru yang lebih modern
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Halaman utama aplikasi sekarang adalah LoginPage
      home: const LoginPage(),
    );
  }
}
