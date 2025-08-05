import 'package:flutter/material.dart';
import 'package:applaporwarga/views/laporan/laporan_form_page.dart'; // Nanti akan dibuat

class HomeUserPage extends StatelessWidget {
  const HomeUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Laporan'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Riwayat Laporan Saya'),
              onTap: () {
                // TODO: Navigasi ke halaman daftar laporan user
                Navigator.pop(context);
                print('Navigasi ke Riwayat Laporan');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // TODO: Implementasi logika logout
                Navigator.pop(context);
                print('Logout ditekan');
              },
            ),
          ],
        ),
      ),
      body: const Center(
        // Placeholder untuk peta
        child: Text('Ini adalah tampilan PETA'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman formulir pelaporan
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LaporanFormPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Laporkan Kerusakan Baru',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                // Saat ini sudah di halaman peta
              },
            ),
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                // TODO: Navigasi ke halaman riwayat laporan
              },
            ),
          ],
        ),
      ),
    );
  }
}
