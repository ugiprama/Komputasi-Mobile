import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomeHeaderWow extends StatefulWidget implements PreferredSizeWidget {
  const HomeHeaderWow({super.key});

  @override
  State<HomeHeaderWow> createState() => _HomeHeaderWowState();

  @override
  Size get preferredSize => const Size.fromHeight(160);
}

class _HomeHeaderWowState extends State<HomeHeaderWow>
    with SingleTickerProviderStateMixin {
  String? fullName;
  bool isLoading = true;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchFullName();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  Future<void> _fetchFullName() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        fullName = "User";
        isLoading = false;
      });
      return;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        fullName = response?['name'] ?? "User";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        fullName = "User";
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            height: widget.preferredSize.height,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF689F99), Color(0xFF4C7C7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTapDown: (_) => _scaleAvatar(1.2),
                  onTapUp: (_) => _scaleAvatar(1.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    transform: Matrix4.identity()..scale(_avatarScale),
                    padding: const EdgeInsets.only(top: 8),
                    child: const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 36, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        isLoading
                            ? 'Hello...'
                            : 'Hello, ${fullName ?? "User"}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Apa yang ingin Anda laporkan hari ini?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    // TODO: navigasi notifikasi
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _avatarScale = 1.0;
  void _scaleAvatar(double scale) {
    setState(() {
      _avatarScale = scale;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _avatarScale = 1.0;
      });
    });
  }
}
