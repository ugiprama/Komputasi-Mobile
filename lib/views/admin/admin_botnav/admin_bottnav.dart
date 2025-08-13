import 'package:flutter/material.dart';
import 'package:applaporwarga/views/admin/admin_home/admin_home_screen.dart';
import 'package:applaporwarga/views/admin/admin_laporan/admin_laporan_page.dart';
import 'package:applaporwarga/views/admin/admin_akun/admin_account_page.dart';

class AdminBottomNavWrapper extends StatefulWidget {
  const AdminBottomNavWrapper({Key? key}) : super(key: key);

  @override
  State<AdminBottomNavWrapper> createState() => _AdminBottomNavWrapperState();
}

class _AdminBottomNavWrapperState extends State<AdminBottomNavWrapper>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // Untuk animasi transisi page
  late final List<Widget> _pages;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pages = const [
      AdminHomeScreen(),
      AdminLaporanPage(),
      AdminAccountPage(),
    ];
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        physics: const BouncingScrollPhysics(),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -1))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey[500],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined),
                activeIcon: Icon(Icons.list_alt),
                label: "Laporan"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: "Akun"),
          ],
        ),
      ),
    );
  }
}
