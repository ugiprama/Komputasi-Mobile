import 'package:flutter/material.dart';

// ALAMAT YANG SALAH SEBELUMNYA:
// import 'home/widgets/home_header.dart';
// import 'home/widgets/latest_reports_section.dart';
// import '../shared/widgets/user_bottom_nav_bar.dart';

// INI ALAMAT YANG BENAR SESUAI STRUKTUR FOLDER KAMU:
import 'package:applaporwarga/views/user/widgets/home_header.dart';
import 'package:applaporwarga/views/user/widgets/latest_reports_section.dart';
import '../../widgets/bottom_nav.dart';

class HomeUserPage extends StatelessWidget {
  // Ini adalah saran dari Flutter, bukan error.
  // Cara penulisan constructor yang lebih modern.
  const HomeUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dengan import yang benar, semua widget ini akan dikenali
    return const Scaffold(
      appBar: HomeHeader(),
      body: LatestReportsSection(),
      bottomNavigationBar: UserBottomNavBar(currentIndex: 0),
    );
  }
}
