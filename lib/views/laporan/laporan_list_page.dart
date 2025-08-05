import 'package:flutter/material.dart';
import 'package:applaporwarga/views/user/home_user_page.dart'; // Import untuk navigasi ke Home

class LaporanListPage extends StatelessWidget {
  const LaporanListPage({super.key});

  final List<Map<String, dynamic>> dummyLaporan = const [
    {
      "judul": "Lampu Merah Roboh",
      "tanggal": "20-5-2025",
      "lokasi": "-7.753695, 110.347617",
      "status": "Proses",
      "foto":
          "https://asset.kompas.com/crops/y8FGM48gZTY-DN3TK0dnpGiNiyI=/0x0:780x520/750x500/data/photo/2023/10/12/6527c02105cf8.jpg"
    },
    {
      "judul": "Jalan Berlubang",
      "tanggal": "20-5-2025",
      "lokasi": "-7.753695, 110.347617",
      "status": "Selesai",
      "foto":
          "https://cdn0-production-images-kly.akamaized.net/ukszDkR3i1nUIYzmdVZ-bBpD9Cg=/640x360/smart/filters:quality(75):strip_icc():format(webp)/kly-media-production/medias/3133217/original/044507400_1594712276-WhatsApp_Image_2020-07-14_at_16.57.07.jpeg"
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Karena ini halaman History
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeUserPage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LaporanListPage()),
            );
          }
          // Index 2, 3, 4 akan ditambahkan nanti
        },
      ),
    );
  }
}
