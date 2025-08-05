import 'package:flutter/material.dart';
import 'package:applaporwarga/views/user/widgets/report_card.dart'; // Import widget yang baru dibuat

class HomeUserPage extends StatelessWidget {
  const HomeUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Header sudah diubah menjadi tampilan custom
        automaticallyImplyLeading: false, // Menghilangkan tombol drawer default
        toolbarHeight: 120,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        // Placeholder for image
                        // backgroundImage: NetworkImage('...'),
                      ),
                      const SizedBox(width: 12.0),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello User',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Ada Kejadian apa hari ini?',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.black),
                        onPressed: () {
                          // TODO: Navigasi ke halaman notifikasi
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.black),
                        onPressed: () {
                          // TODO: Navigasi ke halaman pengaturan
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Laporan Terbaru',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Menggunakan ReportCard widget yang sudah dibuat
            const ReportCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1549492477-d95b5894b9f3?q=80&w=1770&auto=format&fit=crop',
              title: 'Jalan Berlubang',
              date: '20-5-2025',
              location: 'Jalan Kabupaten Sleman',
              coordinate: '-7.753795, 110.347617',
              status: 'Proses',
            ),
            const ReportCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1579290098491-628d32d0f55e?q=80&w=1770&auto=format&fit=crop',
              title: 'Lampu Merah Rusak',
              date: '20-5-2025',
              location: 'Jalan Magelang KM 6',
              coordinate: '-7.745678, 110.342156',
              status: 'Proses',
            ),
            const ReportCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1559817551-7872a0886561?q=80&w=1770&auto=format&fit=crop',
              title: 'Jalan Gelap',
              date: '20-5-2025',
              location: 'Jalan Kaliurang KM 8',
              coordinate: '-7.754321, 110.432156',
              status: 'Proses',
            ),
            const ReportCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1552528766-3d23101c51d9?q=80&w=1770&auto=format&fit=crop',
              title: 'Pembatas Jalan Rusak',
              date: '20-5-2025',
              location: 'Ring Road Utara',
              coordinate: '-7.753210, 110.456789',
              status: 'Proses',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: 'Report'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        onTap: (index) {
          // TODO: Implementasi navigasi bottom bar
        },
      ),
    );
  }
}
