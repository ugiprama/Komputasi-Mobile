import 'package:flutter/material.dart';

class LaporanFormPage extends StatelessWidget {
  const LaporanFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporkan Kerusakan Baru'),
      ),
      body: const Center(
        child: Text('Ini adalah halaman form pelaporan'),
      ),
    );
  }
}
