import 'package:flutter/material.dart';
import 'package:applaporwarga/views/user/home_user_page.dart';
import 'package:applaporwarga/views/laporan/imp_laporan.dart';
import 'package:applaporwarga/views/user/account_page.dart';

class UserBottomNavBar extends StatefulWidget {
  final int currentIndex;

  const UserBottomNavBar({super.key, required this.currentIndex});

  @override
  State<UserBottomNavBar> createState() => _UserBottomNavBarState();
}

class _UserBottomNavBarState extends State<UserBottomNavBar> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    if (index == selectedIndex) return;

    setState(() {
      selectedIndex = index;
    });

    Widget page;
    switch (index) {
      case 0:
        page = const HomeUserPage();
        break;
      case 1:
        page = const LaporanListPage();
        break;
      case 2:
        page = const LaporanPage();
        break;
      case 3:
        page = const AccountPage();
        break;
      default:
        page = const HomeUserPage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home, 'label': 'Home', 'color': Colors.teal},
      {'icon': Icons.history, 'label': 'History', 'color': Colors.orange},
      {'icon': Icons.add_circle, 'label': 'Report', 'color': Colors.purple},
      {'icon': Icons.account_circle, 'label': 'Account', 'color': Colors.blue},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? (item['color'] as Color).withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: isSelected ? item['color'] as Color : Colors.grey[500],
                    size: isSelected ? 30 : 24,
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isSelected ? item['color'] as Color : Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontSize: isSelected ? 14 : 12,
                    ),
                    child: Text(item['label'] as String),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
