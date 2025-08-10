import 'package:flutter/material.dart';
import 'package:applaporwarga/widgets/bottom_nav.dart';
import 'package:applaporwarga/views/laporan/laporan_list_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Ganti data dummy ini dengan data pengguna dari Supabase
    const String userName = 'User';
    const String userImagePath = 'assets/images/user_dummy.png';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 172, 172, 172),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 151, 151),
        title: const Text('AKUN', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(userImagePath),
            ),
            const SizedBox(height: 10),
            // Username
            const Text(
              userName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            // Menu: Riwayat Laporan
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Laporan'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanListPage(),
                  ),
                );
              },
            ),
            // Menu: Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Keluar'),
              onTap: () {
                // TODO: Implementasi logout dari Supabase
                // Contoh Supabase logout nanti:
                // await Supabase.instance.client.auth.signOut();

                // Sementara hanya kembali ke halaman login (dummy)
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 4),
    );
  }
}
