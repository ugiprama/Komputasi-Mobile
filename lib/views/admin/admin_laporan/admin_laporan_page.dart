import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:applaporwarga/views/admin/admin_laporan/admin_detail_lap_page.dart';
import 'package:applaporwarga/views/admin/admin_laporan/helpers/status_helpers.dart';


class AdminLaporanPage extends StatefulWidget {
  const AdminLaporanPage({super.key});

  @override
  State<AdminLaporanPage> createState() => _AdminLaporanPageState();
}

class _AdminLaporanPageState extends State<AdminLaporanPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> laporanList = [];
  String searchQuery = "";
  String sortBy = "waktu_kejadian";
  String? filterStatus;
  String? filterKategori;
  bool isLoading = false;
  Timer? _timer;
  

  final List<String> kategoriList = [
    "Semua",
    "Infrastruktur",
    "Keamanan",
    "Kebersihan",
    "Sosial",
    "Lain-lain"
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id');
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
    fetchLaporan();
  }

  Future<void> fetchLaporan() async {
    setState(() => isLoading = true);

    var query = supabase
        .from('laporan')
        .select('*, profiles(name)');

    if (filterStatus != null && filterStatus!.isNotEmpty) {
      query = query.eq('status', filterStatus!);
    }

    if (filterKategori != null && filterKategori != "Semua") {
      query = query.eq('kategori', filterKategori!);
    }

    if (searchQuery.isNotEmpty) {
      query = query.ilike('judul', '%$searchQuery%');
    }

    final data = await query.order(sortBy, ascending: false);

    setState(() {
      laporanList = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });
  }

  String formatRelativeTime(String? waktu) {
    if (waktu == null) return "-";
    DateTime dt = DateTime.parse(waktu).toLocal();
    DateTime now = DateTime.now();

    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return timeago.format(dt, locale: 'id');
    } 
    else if (dt.year == now.year &&
        dt.month == now.month &&
        now.difference(dt).inDays == 1) {
      return "Kemarin, ${DateFormat('HH:mm', 'id').format(dt)}";
    } 
    else {
      return DateFormat("d MMM yyyy, HH:mm", 'id').format(dt);
    }
  }

  @override
    void dispose() {
      _timer?.cancel();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Masuk",
        style: TextStyle(fontWeight: FontWeight.bold),
        ),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchLaporan,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari laporan...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                      fetchLaporan();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: sortBy,
                  items: const [
                    DropdownMenuItem(
                        value: 'waktu_kejadian', child: Text("Tanggal")),
                    DropdownMenuItem(value: 'status', child: Text("Status")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => sortBy = val);
                      fetchLaporan();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text("Semua"),
                  selected: filterStatus == null,
                  onSelected: (_) {
                    setState(() => filterStatus = null);
                    fetchLaporan();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("Proses"),
                  selected: filterStatus == "Proses",
                  onSelected: (_) {
                    setState(() => filterStatus = "Proses");
                    fetchLaporan();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("Pengerjaan"),
                  selected: filterStatus == "Pengerjaan",
                  onSelected: (_) {
                    setState(() => filterStatus = "Pengerjaan");
                    fetchLaporan();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("Selesai"),
                  selected: filterStatus == "Selesai",
                  onSelected: (_) {
                    setState(() => filterStatus = "Selesai");
                    fetchLaporan();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Filter kategori
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kategoriList.map((kategori) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(kategori),
                    selected: filterKategori == kategori ||
                        (kategori == "Semua" && filterKategori == null),
                    onSelected: (_) {
                      setState(() {
                        filterKategori = kategori == "Semua" ? null : kategori;
                      });
                      fetchLaporan();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchLaporan,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: laporanList.length,
                      itemBuilder: (context, index) {
                        final laporan = laporanList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: statusColor(laporan['status']),
                              child: Icon(
                                statusIcon(laporan['status']),
                                color: Colors.white,),
                            ),
                            title: Text(laporan['judul'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pelapor: ${laporan['profiles']['name'] ?? '-'}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "Kategori: ${laporan['kategori'] ?? '-'}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "Status: ${laporan['status']}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: statusColor(laporan['status']),
                                  ),
                                ),
                                Text(
                                  "Tanggal: ${formatRelativeTime(laporan['created_at'])}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminLaporanDetailPage(laporan: laporan),
                                 ),
                              );
                            },
                          ),
                        );
                      },
                    ),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
