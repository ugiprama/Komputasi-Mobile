import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/bottom_nav.dart';
import 'imp_laporan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

// const double minLat = -7.754; // paling selatan
// const double maxLat = -7.450; // paling utara
// const double minLng = 110.320; // paling barat
// const double maxLng = 110.380; // paling timur

class _LaporanPageState extends State<LaporanPage> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _alamatManualController = TextEditingController();
  List<XFile> _buktiFoto = [];
  String? _selectedKategori;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  LatLng? _lokasi;
  GoogleMapController? _mapController;
  bool _gunakanLokasiSekarang = true;
  int _miniMapId = 0;
  int _uploadFotoKey = 0;
  bool _isInMlati(LatLng lokasi) {
  // return lokasi.latitude >= minLat &&
  //        lokasi.latitude <= maxLat &&
  //        lokasi.longitude >= minLng &&
  //        lokasi.longitude <= maxLng;
  return true;
  }

  


  final List<String> _kategoriMasalah = [
    'Infrastruktur',
    'Keamanan',
    'Kebersihan',
    'Sosial',
    'Lain-lain',
  ];

  @override
  void initState() {
    super.initState();
    _getLokasiSekarang();
  }

  Future<void> _getLokasiSekarang() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _lokasi = LatLng(position.latitude, position.longitude);
    });
  }

  void _setGunakanLokasiSekarang(bool val) {
    setState(() {
      _gunakanLokasiSekarang = val;
      if (!_gunakanLokasiSekarang) _lokasi = null;
      else _getLokasiSekarang();
    });
  }

  void _showToast(String message, {bool error = false}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: error ? Colors.red : Colors.green,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void _resetForm() {
    _judulController.clear();
    _deskripsiController.clear();
    _alamatManualController.clear();
    setState(() {
      _selectedKategori = null;
      _selectedDate = null;
      _selectedTime = null;
      _buktiFoto = [];
      _gunakanLokasiSekarang = true;
      _miniMapId++;
      _uploadFotoKey++;
    });
    _getLokasiSekarang();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }


  void _bukaPetaModal() {
    if (_lokasi == null) return;
    LatLng lokasiSementara = _lokasi!;
    GoogleMapController? modalMapController;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text("Pilih Lokasi Kejadian"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))
          ],
        ),
        body: StatefulBuilder(
          builder: (context, setModalState) => Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(target: lokasiSementara, zoom: 15),
                      onMapCreated: (controller) => modalMapController = controller,
                      onCameraMove: (pos) => lokasiSementara = pos.target,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    ),
                    const Center(child: Icon(Icons.location_pin, size: 40, color: Colors.red))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_isInMlati(lokasiSementara)) {
                          setState(() {
                            _lokasi = lokasiSementara;
                            _miniMapId++;
                          });
                          Navigator.pop(context);
                        } else {
                          _showToast('Lokasi harus berada di Kecamatan Mlati', error: true);
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Simpan Lokasi"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _lokasi = lokasiSementara;
                          _miniMapId++;
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Simpan Lokasi"),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _kirimLaporan() async {
    final judul = _judulController.text.trim();
    final deskripsi = _deskripsiController.text.trim();
    final alamatManual = _alamatManualController.text.trim();

    if (judul.isEmpty) return _showToast('Judul laporan kosong', error: true);
    if (_selectedKategori == null) return _showToast('Kategori belum dipilih', error: true);
    if (deskripsi.isEmpty) return _showToast('Deskripsi kosong', error: true);
    if (_gunakanLokasiSekarang && _lokasi == null) return _showToast('Lokasi belum terdeteksi', error: true);
    if (!_gunakanLokasiSekarang && alamatManual.isEmpty) return _showToast('Alamat harus diisi', error: true);
    if (_selectedDate == null || _selectedTime == null) return _showToast('Tanggal/Waktu harus diisi', error: true);
    if (_buktiFoto.isEmpty) return _showToast('Upload minimal 1 foto', error: true);

    // if (_lokasi != null && !_isInMlati(_lokasi!)) {
    // return _showToast('Koordinat laporan harus berada di Kecamatan Mlati', error: true);
    // }


    try {
      List<String> fotoUrls = [];
      for (var foto in _buktiFoto) {
        final bytes = await foto.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${foto.name}';
        await Supabase.instance.client.storage.from('laporanfoto').uploadBinary(fileName, bytes);
        fotoUrls.add(Supabase.instance.client.storage.from('laporanfoto').getPublicUrl(fileName));
      }

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return _showToast('User belum login', error: true);

      await Supabase.instance.client.from('laporan').insert({
        'user_id': userId,
        'judul': judul,
        'kategori': _selectedKategori,
        'deskripsi': deskripsi,
        'koordinat_lat': _lokasi?.latitude,
        'koordinat_lng': _lokasi?.longitude,
        'alamat_manual': alamatManual.isEmpty ? null : alamatManual,
        'waktu_kejadian': DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ).toIso8601String(),
        'foto_urls': fotoUrls,
      });

      _showToast('Laporan berhasil dikirim!');
      _resetForm();
    } catch (e) {
      _showToast('Gagal kirim laporan: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Laporan Warga', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF26A69A),
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 2),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _kirimLaporan,
        label: const Text("KIRIM"),
        icon: const Icon(Icons.send),
        backgroundColor: const Color(0xFF26A69A),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header peringatan
              Card(
                color: Colors.red.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mohon Jangan Berikan Laporan Palsu',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Judul
              TextField(
                controller: _judulController,
                decoration: InputDecoration(
                  labelText: 'Judul Laporan',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              // Kategori (Chips)
              Text('Kategori Masalah', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _kategoriMasalah.map((kategori) {
                  final selected = _selectedKategori == kategori;
                  return ChoiceChip(
                    label: Text(kategori),
                    selected: selected,
                    selectedColor: const Color(0xFF26A69A),
                    onSelected: (_) => setState(() => _selectedKategori = kategori),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Deskripsi
              TextField(
                controller: _deskripsiController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Masalah',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              // Lokasi
              const Text('Metode Lokasi Kejadian:'),
              Row(
                children: [
                  Radio<bool>(
                      value: true,
                      groupValue: _gunakanLokasiSekarang,
                      onChanged: (val) {
                        if (val != null) _setGunakanLokasiSekarang(val);
                      }),
                  const Text('Gunakan Lokasi Sekarang'),
                  Radio<bool>(
                      value: false,
                      groupValue: _gunakanLokasiSekarang,
                      onChanged: (val) {
                        if (val != null) _setGunakanLokasiSekarang(val);
                      }),
                  const Text('Isi Manual'),
                ],
              ),
              if (_gunakanLokasiSekarang) 
                _lokasi != null
                    ? GestureDetector(
                        onTap: _bukaPetaModal,
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: SizedBox(
                            height: 150,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: GoogleMap(
                                    key: ValueKey('mini_map_$_miniMapId'),
                                    initialCameraPosition: CameraPosition(target: _lokasi!, zoom: 15),
                                    markers: {
                                      Marker(
                                        markerId: const MarkerId('lokasi'),
                                        position: _lokasi!,
                                        draggable: true,
                                        onDragEnd: (newPos) {
                                          if (_isInMlati(newPos)) {
                                            setState(() => _lokasi = newPos);
                                          } else {
                                            _showToast('Lokasi harus berada di Kecamatan Mlati', error: true);
                                            // kembali ke posisi lama
                                            _mapController?.animateCamera(CameraUpdate.newLatLng(_lokasi!));
                                          }
                                        },
                                      ),
                                    },
                                    zoomControlsEnabled: false,
                                    myLocationEnabled: true,
                                    myLocationButtonEnabled: false,
                                    onMapCreated: (c) => _mapController = c,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _bukaPetaModal,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      if (_gunakanLokasiSekarang && _lokasi != null)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            Card(
                              color: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Latitude: ${_lokasi!.latitude.toStringAsFixed(6)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Longitude: ${_lokasi!.longitude.toStringAsFixed(6)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (_gunakanLokasiSekarang && _lokasi == null)
                        const Center(child: CircularProgressIndicator()),

              if (!_gunakanLokasiSekarang)
                TextField(
                  controller: _alamatManualController,
                  decoration: InputDecoration(
                    labelText: 'Alamat Lokasi Kejadian',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              const SizedBox(height: 16),
              // Tanggal & Waktu
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                leading: const Icon(Icons.calendar_today),
                title: Text(
                    (_selectedDate != null && _selectedTime != null)
                    ? DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(
                      DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        _selectedTime?.hour ?? 0,
                        _selectedTime?.minute ?? 0,
                      ),
                      )
                    : 'Pilih Tanggal & Waktu',
                      ),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 16),
              // Foto bukti
              const Text('Foto Bukti', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              UploadFotoMultiWidget(
                key: ValueKey(_uploadFotoKey),
                fotoSebelumnya: _buktiFoto,
                onFotoDiubah: (fotoList) => setState(() => _buktiFoto = fotoList),
              ),
              const SizedBox(height: 80), // padding untuk floating button
            ],
          ),
        ),
      ),
    );
  }
}
