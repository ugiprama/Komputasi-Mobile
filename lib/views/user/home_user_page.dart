import 'package:flutter/material.dart';
import 'package:applaporwarga/views/user/widgets/home_header.dart';
import 'package:applaporwarga/views/laporan/imp_laporan.dart';
import '../../widgets/bottom_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({super.key});

  @override
  State<HomeUserPage> createState() => _HomeUserPageState();
}

class _HomeUserPageState extends State<HomeUserPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  // Menyimpan list laporan (termasuk id) untuk navigasi detail
  List<Map<String, String>> laporanList = [];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    // Setup animasi
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _pageController = PageController(viewportFraction: 0.8);

    _controller.forward();

    _fetchLaporan();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchLaporan() async {
    try {
      final data = await Supabase.instance.client
          .from('laporan')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        laporanList = (data as List<dynamic>)
            .map((item) {
              final map = item as Map<String, dynamic>;
              String? thumb;
              try {
                final fotos = map['foto_urls'];
                if (fotos is List && fotos.isNotEmpty) {
                  final first = fotos.first;
                  if (first != null) thumb = first.toString();
                }
              } catch (_) {}
              return {
                'id': map['id']?.toString() ?? '',
                'title': map['judul']?.toString() ?? 'Tidak ada judul',
                'desc': map['deskripsi']?.toString() ?? 'Tidak ada deskripsi',
                'date': map['created_at'] != null
                    ? map['created_at'].toString().substring(0, 10)
                    : '',
                'thumb': thumb ?? '',
              };
            })
            .where((m) => m['id']!.isNotEmpty)
            .toList();
      });
    } catch (e) {
      print('Error fetch laporan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const HomeHeaderWow(),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LaporanPage()),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Laporan Terbaru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: laporanList.length,
                  itemBuilder: (context, index) {
                    final laporan = laporanList[index];
                    return _buildLaporanCard(laporan);
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Semua Laporan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: laporanList.length,
                  itemBuilder: (context, index) {
                    final item = laporanList[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: _buildThumbnail(item['thumb']),
                        title: Text(item['title']!),
                        subtitle: Text(
                          item['desc']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(item['date']!),
                        onTap: () {
                          final id = item['id'];
                          if (id != null && id.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LaporanDetailPage(laporanId: id),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaporanCard(Map<String, String> laporan) {
    return GestureDetector(
      onTap: () {
        final id = laporan['id'];
        if (id != null && id.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LaporanDetailPage(laporanId: id),
            ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.teal, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                laporan['title']!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                laporan['desc']!,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  laporan['date']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String? url) {
    final placeholder = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.report, color: Colors.orange),
    );

    if (url == null || url.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                placeholder,
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            (progress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
