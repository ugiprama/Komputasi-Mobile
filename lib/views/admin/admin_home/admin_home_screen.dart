import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:applaporwarga/services/admin_laporan_api.dart';
import 'package:applaporwarga/services/admin_laporan_minggu_api.dart';
import 'package:applaporwarga/views/admin/admin_botnav/admin_bottnav.dart';

final supabase = Supabase.instance.client;

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool isLoading = true;
  bool isStatLoading = true;
  List<FlSpot> laporanMingguanSpots = [];
  bool isChartLoading = true;


  Map<String, List<Map<String, dynamic>>> laporanPerKategori = {};
  Map<String, int> statCards = {
    'total': 0,
    'proses': 0,
    'pengerjaan': 0,
    'selesai': 0,
  };

  final laporanApi = AdminLaporanApi();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([
      getLatestReportsPerCategory(),
      getStatCardsData(),
      getLaporanMingguanData(),
    ]);
  }

  Future<void> getLaporanMingguanData() async {
    setState(() => isChartLoading = true);
    try {
      final api = AdminLaporanApiMingguan();
      final data = await api.getLaporanMingguan();

      // Konversi ke FlSpot
      List<FlSpot> spots = [];
      for (int i = 0; i < data.length; i++) {
        spots.add(FlSpot(i.toDouble(), (data[i]['jumlah'] as int).toDouble()));
      }

      setState(() {
        laporanMingguanSpots = spots;
        isChartLoading = false;
      });
    } catch (e) {
      debugPrint('Error ambil data laporan mingguan: $e');
      setState(() => isChartLoading = false);
    }
  }


  Future<void> getStatCardsData() async {
    setState(() => isStatLoading = true);
    try {
      final data = await laporanApi.getStatCardsData();
      setState(() {
        statCards = data;
        isStatLoading = false;
      });
    } catch (e) {
      debugPrint("Error ambil stat cards: $e");
      setState(() => isStatLoading = false);
    }
  }

  Future<void> getLatestReportsPerCategory() async {
    try {
      final response = await supabase
          .from('laporan')
          .select('id, judul, kategori, created_at')
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var item in response) {
        final kategori = item['kategori'] ?? 'Lain-lain';
        grouped.putIfAbsent(kategori, () => []);
        grouped[kategori]!.add(item);
      }

      var sortedEntries = grouped.entries.toList()
        ..sort((a, b) => b.value.length.compareTo(a.value.length));

      setState(() {
        laporanPerKategori = {
          for (var e in sortedEntries) e.key: e.value.take(3).toList()
        };
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error ambil laporan: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Halo, Admin 👋",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ringkasan laporan hari ini.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // ===== STAT CARDS =====
                if (isStatLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(
                          "Laporan", statCards['total'].toString(), Colors.blue),
                      _buildStatCard(
                          "Proses", statCards['proses'].toString(), Colors.orange),
                      _buildStatCard("Pengerjaan",
                          statCards['pengerjaan'].toString(), Colors.purple),
                      _buildStatCard(
                          "Selesai", statCards['selesai'].toString(), Colors.green),
                    ],
                  ),

                const SizedBox(height: 20),

                // ===== CHART =====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Laporan Mingguan",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12,),
                      isChartLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(height: 200, child: _WeeklyReportsChart(spots: laporanMingguanSpots)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===== LATEST REPORTS PER CATEGORY =====
                const Text(
                  "Laporan Terbaru",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (laporanPerKategori.isEmpty)
                  const Text("Belum ada laporan.")
                else
                  Column(
                    children: laporanPerKategori.entries.map((entry) {
                      final kategori = entry.key;
                      final laporanList = entry.value;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kategori.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              for (var laporan in laporanList)
                                _buildReportTile(
                                  laporan['judul'] ?? 'Tanpa Judul',
                                  DateFormat('dd MMM yyyy, HH:mm').format(
                                    DateTime.parse(
                                        laporan['created_at'].toString()),
                                  ),
                                  Colors.blue,
                                ),
                              // Align(
                              //   alignment: Alignment.centerRight,
                              //   child: TextButton(
                              //     onPressed: () {
                              //     },
                              //     child: const Text("Lihat Semua"),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 85,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTile(String title, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(Icons.warning, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(time,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyReportsChart extends StatelessWidget {
  final List<FlSpot> spots;

  const _WeeklyReportsChart({this.spots = const []});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: spots.isEmpty ? 10 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2,
        clipData: FlClipData.all(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                const days = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(days[value.toInt()],
                      style: const TextStyle(fontSize: 12));
                }
                return const Text("");
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots.isEmpty 
            ? const[
              FlSpot(0, 0),
              FlSpot(1, 0),
              FlSpot(2, 0),
              FlSpot(3, 0),
              FlSpot(4, 0),
              FlSpot(5, 0),
              FlSpot(6, 0),
            ]
            : spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            belowBarData:
                BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
