import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/bottom_nav.dart';
import 'imp_laporan.dart';

class LaporanListPage extends StatefulWidget {
  const LaporanListPage({super.key});

  @override
  State<LaporanListPage> createState() => _LaporanListPageState();
}

class _LaporanListPageState extends State<LaporanListPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _laporanList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await supabase
          .from('laporan')
          .select()
          .order('waktu_kejadian', ascending: false);

      setState(() {
        _laporanList = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proses':
        return Colors.red;
      case 'selesai':
        return Colors.green;
      case 'pengerjaan':
        return Colors.amber; // kuning
      default:
        return Colors.grey;
    }
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return '-';
    }
  }

  String formatLokasi(double? lat, double? lng) {
    if (lat == null || lng == null) return '-';
    return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Laporan"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _laporanList.isEmpty
                  ? const Center(child: Text('Belum ada laporan'))
                  : ListView.builder(
                      itemCount: _laporanList.length,
                      itemBuilder: (context, index) {
                        final laporan = _laporanList[index];
                        final status = laporan['status'] ?? '';
                        final statusColor = getStatusColor(status);

                        String fotoUrl = '';
                        if (laporan['foto_urls'] != null) {
                          final List<dynamic> fotoList = List<dynamic>.from(laporan['foto_urls']);
                          if (fotoList.isNotEmpty) {
                            fotoUrl = fotoList[0] is String ? fotoList[0] : '';
                          }
                        }

                        return InkWell(
                          onTap: () async {
                            final laporanId = laporan['id'];
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LaporanDetailPage(laporanId: laporanId),
                              ),
                            );

                            if (result == true) {
                              await _fetchLaporan();
                              setState(() {
                              });
                            }
                          },

                        child: Container(
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

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: fotoUrl.isNotEmpty
                                          ? Image.network(
                                              fotoUrl,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 70,
                                                height: 70,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 70,
                                              height: 70,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                    title: Text(
                                      laporan['judul'] ?? '-',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Tanggal : ${formatDate(laporan['waktu_kejadian'])}"),
                                        Text("Lokasi : ${formatLokasi(laporan['koordinat_lat'], laporan['koordinat_lng'])}"),
                                        Text("Status : $status"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        );
                      },
                    ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 1),
    );
  }
}
