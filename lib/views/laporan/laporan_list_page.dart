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
enum SortOption { terbaru, terlama, status }

class _LaporanListPageState extends State<LaporanListPage> {
  final supabase = Supabase.instance.client;
  SortOption _selectedSort = SortOption.terbaru;


  List<Map<String, dynamic>> _laporanList = [];
  bool _loading = true;
  String? _error;
  
  

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await supabase
          .from('laporan')
          .select()
          .eq('user_id', user.id)
          .order(
            _selectedSort == SortOption.terlama ? 'waktu_kejadian' : _selectedSort == SortOption.terbaru ? 'waktu_kejadian' : 'status',
            ascending: _selectedSort == SortOption.terlama ? true : _selectedSort == SortOption.terbaru ? false : true,
          );
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
        return Colors.redAccent;
      case 'selesai':
        return Colors.green;
      case 'pengerjaan':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy').format(dt);
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
        backgroundColor: Colors.teal,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Riwayat Laporan",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PopupMenuButton<SortOption>(
              icon: const Icon(Icons.sort, color: Colors.white),
              onSelected: (value) {
                setState(() {
                  _selectedSort = value;
                });
                _fetchLaporan(); // refresh data setelah sort
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: SortOption.terbaru,
                  child: Row(
                    children: [
                      Icon(Icons.update,
                          color: _selectedSort == SortOption.terbaru
                              ? Colors.teal
                              : Colors.grey),
                      const SizedBox(width: 8),
                      const Text("Tanggal Terbaru"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.terlama,
                  child: Row(
                    children: [
                      Icon(Icons.update_disabled,
                          color: _selectedSort == SortOption.terlama
                              ? Colors.teal
                              : Colors.grey),
                      const SizedBox(width: 8),
                      const Text("Tanggal Terlama"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.status,
                  child: Row(
                    children: [
                      Icon(Icons.info,
                          color: _selectedSort == SortOption.status
                              ? Colors.teal
                              : Colors.grey),
                      const SizedBox(width: 8),
                      const Text("Status"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _laporanList.isEmpty
                  ? const Center(child: Text('Belum ada laporan'))
                  : RefreshIndicator(
                      onRefresh: _fetchLaporan,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _laporanList.length,
                        itemBuilder: (context, index) {
                          final laporan = _laporanList[index];
                          final status = laporan['status'] ?? '';
                          final statusColor = getStatusColor(status);

                          String fotoUrl = '';
                          if (laporan['foto_urls'] != null) {
                            final List<dynamic> fotoList =
                                List<dynamic>.from(laporan['foto_urls']);
                            if (fotoList.isNotEmpty) {
                              fotoUrl = fotoList[0] is String ? fotoList[0] : '';
                            }
                          }

                          return GestureDetector(
                            onTap: () async {
                              final laporanId = laporan['id'];
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      LaporanDetailPage(laporanId: laporanId),
                                ),
                              );

                              if (result == true) {
                                await _fetchLaporan();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Strip warna mengikuti tinggi card
                                    Container(
                                      width: 8,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    laporan['judul'] ?? '-',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                                Text(
                                                  status,
                                                  style: TextStyle(
                                                      color: statusColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                                "Tanggal : ${formatDate(laporan['waktu_kejadian'])}"),
                                            Text(
                                                "Lokasi : ${formatLokasi(laporan['koordinat_lat'], laporan['koordinat_lng'])}"),
                                            const SizedBox(height: 8),
                                            if (fotoUrl.isNotEmpty)
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  fotoUrl,
                                                  height: 150,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder:
                                                      (context, child, loading) {
                                                    if (loading == null)
                                                      return child;
                                                    return Container(
                                                      height: 150,
                                                      color: Colors.grey[200],
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    height: 150,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 1),
    );
  }
}
