import 'package:applaporwarga/views/user/home_user_page.dart';
import 'package:flutter/material.dart';
import 'package:applaporwarga/views/auth/login_page.dart';
import 'package:applaporwarga/views/laporan/imp_laporan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lapor Warga',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Halaman login akan menjadi halaman utama
      home: const HomeUserPage(),
    );
  }
}
