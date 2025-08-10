import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'imp_laporan.dart'; // pastikan ada import LaporanEditPage

class LaporanDetailPage extends StatefulWidget {
  final String laporanId;

  const LaporanDetailPage({super.key, required this.laporanId});

  @override
  State<LaporanDetailPage> createState() => _LaporanDetailPageState();
}

class _LaporanDetailPageState extends State<LaporanDetailPage> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? _laporanDetail;
  String _namaPelapor = '-';
  bool _loading = true;
  bool _dataUpdated = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });

    try {
      // Fetch laporan detail
      final laporan = await supabase
          .from('laporan')
          .select()
          .eq('id', widget.laporanId)
          .single();

      if (laporan != null) {
        setState(() {
          _laporanDetail = laporan;
        });

        // Fetch nama pelapor berdasarkan user_id laporan
        final userId = laporan['user_id'];
        if (userId != null) {
          final profile = await supabase
              .from('profiles')
              .select('name')
              .eq('id', userId)
              .maybeSingle();

          setState(() {
            _namaPelapor = profile?['name'] ?? '-';
          });
        } else {
          setState(() {
            _namaPelapor = '-';
          });
        }
      }
    } catch (e) {
      print('Error fetching laporan detail or profile: $e');
      // Kamu bisa tambah error handling dan tampilkan pesan error di UI jika perlu
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String formatDateTime(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_laporanDetail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Laporan')),
        body: const Center(child: Text('Laporan tidak ditemukan')),
      );
    }

    final laporan = _laporanDetail!;
    final status = laporan['status'] ?? '-';
    final judul = laporan['judul'] ?? '-';
    final kategori = laporan['kategori'] ?? '-';
    final deskripsi = laporan['deskripsi'] ?? '-';
    final alamatManual = laporan['alamat_manual'];
    final lat = laporan['koordinat_lat'];
    final lng = laporan['koordinat_lng'];
    final waktuKejadian = laporan['waktu_kejadian'];

    final fotoUrls = laporan['foto_urls'] as List<dynamic>? ?? [];

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dataUpdated);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Laporan'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _dataUpdated),
          ),
          backgroundColor: const Color.fromRGBO(104, 159, 153, 1),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      judul,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                'Pelapor: $_namaPelapor',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              _infoRow('Kategori Masalah:', kategori),
              const SizedBox(height: 8),
              _infoRow('Deskripsi Masalah:', deskripsi),
              const SizedBox(height: 8),

              _infoRow(
                'Lokasi Kejadian:',
                alamatManual != null && alamatManual.toString().isNotEmpty
                    ? alamatManual
                    : (lat != null && lng != null
                        ? '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}'
                        : '-'),
              ),
              const SizedBox(height: 8),

              _infoRow(
                'Tanggal & Waktu:',
                waktuKejadian != null ? formatDateTime(waktuKejadian) : '-',
              ),
              const SizedBox(height: 16),

              const Text(
                'Foto Bukti',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 120,
                child: fotoUrls.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada foto bukti',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: fotoUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final fotoUrl = fotoUrls[index].toString();
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              fotoUrl,
                              width: 140,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 140,
                                height: 120,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LaporanEditPage(laporan: laporan),
                        ),
                      );

                      if (updated == true) {
                        _dataUpdated = true;
                        await _loadData();
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Edit Laporan',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Konfirmasi Hapus'),
                          content: const Text('Yakin ingin menghapus laporan ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final response = await supabase
                            .from('laporan')
                            .delete()
                            .eq('id', laporan['id']);

                        if (response.error == null) {
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal hapus laporan: ${response.error!.message}')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Hapus Laporan',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        )
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proses':
        return Colors.red;
      case 'pengerjaan':
        return Colors.amber;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
