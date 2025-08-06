import 'package:flutter/material.dart';
import 'package:applaporwarga/views/user/widgets/report_card.dart'; // Re-use ReportCard
import 'package:applaporwarga/widgets/bottom_nav.dart'; // Import nav bar

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // DATA DUMMY: Nanti ini akan kita ambil dari Supabase
    // dengan query "tampilkan laporan di mana user_id = id_user_sekarang"
    final List<Map<String, String>> myReports = [
      {
        "imageUrl": 'https://picsum.photos/seed/10/400/200',
        "title": 'Got Bocor di Depan Rumah',
        "date": '01-08-2025',
        "location": 'Rumah saya, Blok C-12',
        "status": 'Selesai',
      },
      {
        "imageUrl": 'https://picsum.photos/seed/11/400/200',
        "title": 'Tiang Listrik Miring',
        "date": '15-07-2025',
        "location": 'Dekat taman bermain',
        "status": 'Proses',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Laporan Saya'),
        backgroundColor: Colors.white,
        elevation: 1,
        // Menghilangkan tombol kembali otomatis
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: myReports.length,
        itemBuilder: (context, index) {
          final report = myReports[index];
          return ReportCard(
            imageUrl: report['imageUrl']!,
            title: report['title']!,
            date: report['date']!,
            location: report['location']!,
            // Kita belum pakai coordinate di sini untuk sementara
            coordinate: '',
            status: report['status']!,
          );
        },
      ),
      // Jangan lupa pasang BottomNavBar, dengan index aktif di 'History' (index 1)
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 1),
    );
  }
}
