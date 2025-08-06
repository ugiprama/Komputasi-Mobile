import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';

class LaporanListPage extends StatelessWidget {
  const LaporanListPage({super.key});

  final List<Map<String, dynamic>> dummyLaporan = const [
    {
      "judul": "Lampu Merah Roboh",
      "tanggal": "20-5-2025",
      "lokasi": "-7.753695, 110.347617",
      "status": "Proses",
      "foto":
          "https://picsum.photos/seed/10/400/200"
    },
    {
      "judul": "Jalan Berlubang",
      "tanggal": "20-5-2025",
      "lokasi": "-7.753695, 110.347617",
      "status": "Selesai",
      "foto":
          "https://picsum.photos/seed/11/400/200"
    },
  ];

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proses':
        return Colors.red;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Laporan"),
      ),
      body: ListView.builder(
        itemCount: dummyLaporan.length,
        itemBuilder: (context, index) {
          final laporan = dummyLaporan[index];
          final statusColor = getStatusColor(laporan["status"]);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                // Status Color Strip
                Container(
                  width: 8,
                  height: 120,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          laporan["foto"],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        laporan["judul"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tanggal : ${laporan["tanggal"]}"),
                          Text("Lokasi : ${laporan["lokasi"]}"),
                          Text("Status : ${laporan["status"]}"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 1),
    );
  }
}
