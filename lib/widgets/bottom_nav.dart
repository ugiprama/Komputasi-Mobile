// BOTTOM NAV NYA DI JADIKAN SATU FILE

import 'package:flutter/material.dart';
import 'package:applaporwarga/views/user/home_user_page.dart';
import 'package:applaporwarga/views/laporan/imp_laporan.dart';

class UserBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const UserBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Report'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Notifikasi'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), label: 'Account'),
      ],
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeUserPage()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LaporanListPage()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LaporanPage()),
            );
            break;
        }
      },
    );
  }
}
