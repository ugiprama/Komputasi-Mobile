import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:applaporwarga/views/user/widgets/report_card.dart';
import 'package:applaporwarga/views/laporan/laporan_detail_page.dart';

class LatestReportsSection extends StatefulWidget {
  const LatestReportsSection({super.key});

  @override
  State<LatestReportsSection> createState() => _LatestReportsSectionState();
}

class _LatestReportsSectionState extends State<LatestReportsSection> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _laporanList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLatestReports();
  }

  Future<void> _fetchLatestReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await supabase
          .from('laporan')
          .select()
          .order('waktu_kejadian', ascending: false)
          .limit(5);

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
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: $_error'),
              )
            : _laporanList.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Belum ada laporan terbaru'),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'Laporan Terbaru',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ..._laporanList.map((laporan) {
                          String fotoUrl = '';
                          if (laporan['foto_urls'] != null) {
                            final List<dynamic> fotoList =
                                List<dynamic>.from(laporan['foto_urls']);
                            if (fotoList.isNotEmpty) {
                              fotoUrl = fotoList[0] is String
                                  ? fotoList[0]
                                  : '';
                            }
                          }

                          return InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LaporanDetailPage(
                                    laporanId: laporan['id'].toString(),
                                  ),
                                ),
                              );

                              // Refresh jika ada update
                              if (result == true) {
                                await _fetchLatestReports();
                              }
                            },
                            child: ReportCard(
                              imageUrl: fotoUrl.isNotEmpty
                                  ? fotoUrl
                                  : 'https://via.placeholder.com/400x200.png?text=No+Image',
                              title: laporan['judul'] ?? '-',
                              date: formatDate(laporan['waktu_kejadian']),
                              location: laporan['lokasi'] ?? '-',
                              coordinate: formatLokasi(
                                laporan['koordinat_lat'],
                                laporan['koordinat_lng'],
                              ),
                              status: laporan['status'] ?? '-',
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
  }
}
