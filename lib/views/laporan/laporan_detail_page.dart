import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:applaporwarga/views/laporan/laporan_edit_page.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'laporan_photo_viewer_page.dart';

class LaporanDetailPage extends StatefulWidget {
  final String laporanId;
  const LaporanDetailPage({super.key, required this.laporanId});

  @override
  State<LaporanDetailPage> createState() => _LaporanDetailPageState();
}

class _LaporanDetailPageState extends State<LaporanDetailPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? laporan;
  String namaPelapor = '-';
  bool loading = true;
  bool dataUpdated = false;
  bool isOwner = false;
  String? resolvedAddress;
  bool addressLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    try {
      final data = await supabase
          .from('laporan')
          .select()
          .eq('id', widget.laporanId)
          .single();

      laporan = data;

      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId != null && data['user_id'] == currentUserId) {
        isOwner = true;
      } else {
        isOwner = false;
      }

      if (data['user_id'] != null) {
        final profile = await supabase
            .from('profiles')
            .select('name')
            .eq('id', data['user_id'])
            .maybeSingle();
        namaPelapor = profile?['name'] ?? '-';
      }

      final lat = (data['koordinat_lat'] as num?)?.toDouble();
      final lng = (data['koordinat_lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        _reverseGeocode(lat, lng);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    setState(() => loading = false);
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    setState(() => addressLoading = true);
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.postalCode
        ]
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (mounted) {
          setState(() {
            resolvedAddress = parts.join(', ');
          });
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    } finally {
      if (mounted) {
        setState(() => addressLoading = false);
      }
    }
  }

  String formatDateTime(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (laporan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Laporan')),
        body: const Center(child: Text('Laporan tidak ditemukan')),
      );
    }

    final fotoUrls = List<String>.from(laporan?['foto_urls'] ?? []);
    // Gunakan casting num? agar aman jika Supabase mengembalikan int
    final lat = (laporan?['koordinat_lat'] as num?)?.toDouble();
    final lng = (laporan?['koordinat_lng'] as num?)?.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: const Color(0xFF689F99),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (fotoUrls.isNotEmpty) _buildImageCarousel(fotoUrls),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            if (lat != null && lng != null) _buildMapPreview(lat, lng),
            const SizedBox(height: 24),
            if (isOwner) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final status = laporan?['status'] ?? '-';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            laporan?['judul'] ?? '-',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Chip(
          avatar: const Icon(Icons.info, color: Colors.white, size: 18),
          label: Text(
            status,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: _statusColor(status),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<String> urls) {
    return CarouselSlider.builder(
      options: CarouselOptions(
        height: 200,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
      ),
      itemCount: urls.length,
      itemBuilder: (context, index, realIdx) {
        final url = urls[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LaporanPhotoViewerPage(
                  fotoUrls: urls,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Hero(
            tag: 'laporan_foto_${index}$url',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image,
                      size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard() {
    final lat = (laporan?['koordinat_lat'] as num?)?.toDouble();
    final lng = (laporan?['koordinat_lng'] as num?)?.toDouble();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoTile(Icons.person, "Pelapor", namaPelapor),
            _infoTile(Icons.category, "Kategori", laporan?['kategori'] ?? '-'),
            _infoTile(
                Icons.description, "Deskripsi", laporan?['deskripsi'] ?? '-'),
            _infoTile(
              Icons.location_on,
              "Lokasi",
              () {
                if (addressLoading) return 'Mencari alamat...';
                final manual = (laporan?['alamat_manual'] as String?)?.trim();
                if (manual != null && manual.isNotEmpty) return manual;
                if (resolvedAddress != null &&
                    resolvedAddress!.trim().isNotEmpty) {
                  return resolvedAddress!;
                }
                return 'Alamat tidak tersedia';
              }(),
            ),
            _infoTile(
                Icons.map,
                "Koordinat",
                (lat != null && lng != null)
                    ? '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'
                    : '-'),
            _infoTile(Icons.calendar_today, "Tanggal & Waktu",
                formatDateTime(laporan?['waktu_kejadian'])),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview(double lat, double lng) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: 15,
          ),
          markers: {
            Marker(
                markerId: const MarkerId('laporan'),
                position: LatLng(lat, lng)),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF689F99)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LaporanEditPage(laporan: laporan!), // Pastikan import
              ),
            );

            if (updated == true) {
              setState(() => dataUpdated = true);
              await _loadData();
            }
          },
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text("Edit", style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Konfirmasi Hapus"),
                content: const Text("Yakin ingin menghapus laporan ini?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Batal"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Hapus"),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              try {
                await supabase
                    .from('laporan')
                    .delete()
                    .eq('id', laporan?['id']);
                Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal hapus laporan: $e')),
                );
              }
            }
          },
          icon: const Icon(Icons.delete, color: Colors.white),
          label: const Text("Hapus", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proses':
        return Colors.red;
      case 'pengerjaan':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
