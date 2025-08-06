import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/bottom_nav.dart';
import 'imp_laporan.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({Key? key}) : super(key: key);

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

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

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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
    LatLng _lokasiSementara = _lokasi!;
    GoogleMapController? _modalMapController;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Pilih Lokasi Kejadian"),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _lokasiSementara,
                            zoom: 15,
                          ),
                          onMapCreated: (controller) {
                            _modalMapController = controller;
                          },
                          onCameraMove: (position) {
                            _lokasiSementara = position.target;
                          },
                          zoomControlsEnabled: false,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                        ),
                        const Center(
                          child: Icon(
                            Icons.location_pin,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final position = await Geolocator.getCurrentPosition();
                            final newPosition = LatLng(position.latitude, position.longitude);

                            setModalState(() {
                              _lokasiSementara = newPosition;
                            });
                            if (_modalMapController != null) {
                              _modalMapController!.animateCamera(
                                CameraUpdate.newLatLng(newPosition),
                              );
                            }
                          },
                          icon: const Icon(Icons.my_location),
                          label: const Text("Lokasi Sekarang"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _lokasi = _lokasiSementara;
                              _miniMapId++;
                            });
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Simpan Lokasi'),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _kirimLaporan() {
    final judul = _judulController.text.trim();
    final deskripsi = _deskripsiController.text.trim();
    final alamatManual = _alamatManualController.text.trim();

    if (judul.isEmpty ||
        _selectedKategori == null ||
        deskripsi.isEmpty ||
        (_gunakanLokasiSekarang && _lokasi == null) ||
        (!_gunakanLokasiSekarang && alamatManual.isEmpty) ||
        _buktiFoto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data sebelum mengirim laporan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan berhasil dikirim!'),
        backgroundColor: Colors.green,
      ),
    );

    _judulController.clear();
    _deskripsiController.clear();
    _alamatManualController.clear();
    setState(() {
      _selectedKategori = null;
      _selectedDate = null;
      _selectedTime = null;
      _buktiFoto = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan Warga',
          style: TextStyle(color: Colors.white),
          ),
        backgroundColor: const Color.fromRGBO(104, 159, 153, 1),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ElevatedButton(
              onPressed: _kirimLaporan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('KIRIM'),
            ),
          )
        ],
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 2),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 5), // jarak bawah ke form
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Mohon Jangan Berikan Laporan Palsu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Laporan',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                items: _kategoriMasalah
                    .map((kategori) => DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedKategori = val),
                decoration: const InputDecoration(
                  labelText: 'Kategori Masalah',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Masalah',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Metode Lokasi Kejadian:'),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: _gunakanLokasiSekarang,
                    onChanged: (val) => setState(() => _gunakanLokasiSekarang = val!),
                  ),
                  const Text('Gunakan Lokasi Sekarang'),
                  Radio<bool>(
                    value: false,
                    groupValue: _gunakanLokasiSekarang,
                    onChanged: (val) => setState(() => _gunakanLokasiSekarang = val!),
                  ),
                  const Text('Isi Manual'),
                ],
              ),
              if (_gunakanLokasiSekarang && _lokasi != null)
                Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: GoogleMap(
                              key: ValueKey('mini_map_$_miniMapId'),
                              initialCameraPosition: CameraPosition(
                                target: _lokasi!,
                                zoom: 15,
                              ),
                              onMapCreated: (controller) {
                                _mapController = controller;
                              },
                              zoomControlsEnabled: false,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              onTap: (_) => _bukaPetaModal(),
                              markers: {
                                Marker(
                                  markerId: const MarkerId('lokasi'),
                                  position: _lokasi!,
                                ),
                              },
                              gestureRecognizers: {},
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _bukaPetaModal,
                                child: const Center(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Koordinat Lokasi:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_lokasi!.latitude.toStringAsFixed(5)}, ${_lokasi!.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (!_gunakanLokasiSekarang)
                TextFormField(
                  controller: _alamatManualController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Lokasi Kejadian',
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity(vertical: -4),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _selectedDate == null
                        ? 'Tanggal dan Waktu Kejadian'
                        : DateFormat('dd MMM yyyy, hh:mm a').format(
                            DateTime(
                              _selectedDate!.year,
                              _selectedDate!.month,
                              _selectedDate!.day,
                              _selectedTime?.hour ?? 0,
                              _selectedTime?.minute ?? 0,
                            ),
                          ),
                  ),
                  leading: const Icon(Icons.calendar_today),
                  onTap: _pickDateTime,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Foto Bukti'),
              const SizedBox(height: 8),
              UploadFotoMultiWidget(
                fotoSebelumnya: _buktiFoto,
                onFotoDiubah: (fotoList) {
                  setState(() {
                    _buktiFoto = fotoList;
                  });
                },
              ),


            ],
          ),
        ),
      ),
    );
  }
}
