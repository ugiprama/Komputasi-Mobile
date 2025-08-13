import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

// Helpers
import 'helpers/status_helpers.dart';
import 'helpers/maps_share.dart';
import 'helpers/notif_helper.dart';

// Status update logic & UI
import 'status_update/status_update_sheet.dart';
import 'status_update/status_update_logic.dart';

// Widgets
import 'widgets/section_card.dart';
import 'widgets/key_value_row.dart';
import 'widgets/laporan_header.dart';
import 'widgets/laporan_gallery.dart';
import 'widgets/laporan_location.dart';
import 'widgets/laporan_reporter.dart';
import 'widgets/laporan_notes.dart';

class AdminLaporanDetailPage extends StatefulWidget {
  final Map<String, dynamic> laporan;

  const AdminLaporanDetailPage({super.key, required this.laporan});

  @override
  State<AdminLaporanDetailPage> createState() => _AdminLaporanDetailPageState();
}

class _AdminLaporanDetailPageState extends State<AdminLaporanDetailPage> {
  final supabase = Supabase.instance.client;
  late Map<String, dynamic> data;
  bool updating = false;

  late StatusUpdateLogic statusUpdateLogic;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    data = Map<String, dynamic>.from(widget.laporan);
    statusUpdateLogic = StatusUpdateLogic(supabase: supabase, context: context);
  }

  String _formatRelative(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return timeago.format(dt, locale: 'id');
      }
      if (DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1))
          .isAtSameMomentAs(DateTime(dt.year, dt.month, dt.day))) {
        return "Kemarin, ${DateFormat('HH:mm', 'id').format(dt)}";
      }
      return DateFormat("d MMM yyyy, HH:mm", 'id').format(dt);
    } catch (_) {
      return iso!;
    }
  }

  String _formatAbsolute(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat("EEEE, d MMM yyyy • HH:mm", 'id').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Color _statusColor(String? s) => statusColor(s);

  IconData _statusIcon(String? s) => statusIcon(s);

  Future<void> _showUpdateStatusSheet() async {
    final id = data['id'] as String?;
    if (id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID laporan tidak valid')));
      return;
    }

    final currentStatus = (data['status'] ?? 'Proses').toString();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatusUpdateSheet(
        currentStatus: currentStatus,
        onSave: (selectedStatus, note) async {
          final confirm = await statusUpdateLogic.showConfirmDialog(selectedStatus);
          if (!confirm) return;

          await statusUpdateLogic.updateStatus(
            id: id,
            status: selectedStatus,
            note: note,
            onStart: () => setState(() => updating = true),
            onEnd: () => setState(() => updating = false),
            onSuccess: (status) {
              if (!mounted) return;
              setState(() {
                data['status'] = status;
                if (note != null) data['catatan_admin'] = note;
              });
              showCustomNotification(
                context,
                message: 'Status diubah ke "$status"',
                backgroundColor: _statusColor(status),
                icon: _statusIcon(status),
              );

            },
            onError: (error) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengubah status: $error')));
            },
          );
        },
      ),
    );
  }

  Future<void> _copyId() async {
    await Clipboard.setData(ClipboardData(text: data['id'] ?? ''));
    if (!mounted) return;
    showCustomNotification(
      context,
      message: 'ID laporan disalin',
      icon: Icons.copy,
      backgroundColor: Colors.blueGrey,
    );
  }

  Future<void> _shareSummary() async {
    final profiles = data['profiles'] as Map<String, dynamic>? ?? {};
    final pelaporName = profiles['name'] ?? profiles['nama_lengkap'] ?? '-';

    final ringkas =
      'Laporan: ${data['judul'] ?? '-'}\n'
      'Status: ${data['status'] ?? 'Proses'}\n'
      'Kategori: ${data['kategori'] ?? '-'}\n'
      'Waktu: ${_formatAbsolute(data['created_at']?.toString())}\n'
      'Pelapor: $pelaporName\n'
      'ID: ${data['id'] ?? '-'}';

    await shareText(context, ringkas);
  }

  @override
  Widget build(BuildContext context) {
    final id = (data['id'] ?? '') as String;
    final judul = (data['judul'] ?? '-') as String;
    final deskripsi = (data['deskripsi'] ?? '-') as String;
    final kategori = (data['kategori'] ?? '-') as String;
    final status = (data['status'] ?? 'Proses') as String;
    final createdAt = data['created_at']?.toString();
    final waktuKejadian = createdAt;
    final alamatManual = (data['alamat_manual'] ?? '') as String;
    final lat = (data['koordinat_lat'] as num?)?.toDouble();
    final lng = (data['koordinat_lng'] as num?)?.toDouble();
    print("DATA LAPORAN: $data");
    print("Lat: $lat, Lng: $lng");
    final fotoUrls = (data['foto_urls'] as List?)?.cast<String>() ?? const <String>[];
    final pelapor = data['profiles'] as Map<String, dynamic>? ?? const {};
    final namaPelapor = (pelapor['name'] ?? pelapor['nama_lengkap'] ?? '-') as String;
    final emailPelapor = (pelapor['email'] ?? '') as String;
    final telpPelapor = (pelapor['phone'] ?? pelapor['no_telp'] ?? '') as String;
    final catatanAdmin = (data['catatan_admin'] ?? '') as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        actions: [
          IconButton(
            tooltip: 'Salin ID',
            icon: const Icon(Icons.copy),
            onPressed: _copyId,
          ),
          IconButton(
            tooltip: 'Bagikan (salin ringkasan)',
            icon: const Icon(Icons.share),
            onPressed: _shareSummary,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: updating ? null : _showUpdateStatusSheet,
        icon: updating
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.sync_alt),
        label: Text(updating ? 'Menyimpan...' : 'Ubah Status'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LaporanHeader(
            id: id,
            judul: judul,
            status: status,
            kategori: kategori,
            waktuKejadian: waktuKejadian,
            createdAt: createdAt,
            onCopyId: _copyId,
            onShare: _shareSummary,
          ),
          const SizedBox(height: 16),
          if (fotoUrls.isNotEmpty)
            LaporanGallery(fotoUrls: fotoUrls, laporanId: id),
          SectionCard(
            title: 'Deskripsi',
            child: Text(
              deskripsi.isEmpty ? '-' : deskripsi,
              style: const TextStyle(height: 1.4),
            ),
          ),
          SectionCard(
            title: 'Lokasi Kejadian',
            child: LaporanLocation(
              alamatManual: alamatManual,
              lat: lat,
              lng: lng,
            ),
          ),
          SectionCard(
            title: 'Pelapor',
            child: LaporanReporter(
              namaPelapor: namaPelapor,
              emailPelapor: emailPelapor,
              telpPelapor: telpPelapor,
            ),
          ),
          if (catatanAdmin.trim().isNotEmpty)
            SectionCard(
              title: 'Catatan Admin',
              child: Text(catatanAdmin.trim()),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
