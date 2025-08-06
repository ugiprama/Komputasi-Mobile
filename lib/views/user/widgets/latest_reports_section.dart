import 'package:flutter/material.dart';
import 'package:applaporwarga/views/user/widgets/report_card.dart'; // Sesuaikan path jika perlu

class LatestReportsSection extends StatelessWidget {
  // const LatestReportsSection({super.key}); // Uncomment jika Flutter versi baru
  const LatestReportsSection({Key? key}) : super(key: key); // Gunakan ini

  @override
  Widget build(BuildContext context) {
    // Di masa depan, data ini akan datang dari Supabase, bukan hardcoded.
    // Kita akan menggunakan ListView.builder di sini.
    return SingleChildScrollView(
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
          // Untuk sementara, kita masih pakai data hardcoded
          // Nanti kita ganti dengan ListView.builder
          const ReportCard(
            // ... parameter ...
            imageUrl:
                'https://picsum.photos/seed/1/400/200', // Gunakan link placeholder
            title: 'Jalan Berlubang',
            date: '20-5-2025',
            location: 'Jalan Kabupaten Sleman',
            coordinate: '-7.753795, 110.347617',
            status: 'Proses',
          ),
          const ReportCard(
            // ... parameter ...
            imageUrl: 'https://picsum.photos/seed/2/400/200',
            title: 'Lampu Merah Rusak',
            date: '20-5-2025',
            location: 'Jalan Magelang KM 6',
            coordinate: '-7.745678, 110.342156',
            status: 'Proses',
          ),
          // ... Laporan lainnya ...
        ],
      ),
    );
  }
}
