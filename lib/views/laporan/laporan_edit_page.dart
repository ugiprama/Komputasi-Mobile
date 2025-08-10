import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'imp_laporan.dart';

class LaporanEditPage extends StatefulWidget {
  final Map<String, dynamic> laporan;

  const LaporanEditPage({super.key, required this.laporan});

  @override
  State<LaporanEditPage> createState() => _LaporanEditPageState();
}

class _LaporanEditPageState extends State<LaporanEditPage> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _alamatManualController = TextEditingController();
  List<XFile> _buktiFotoBaru = []; // foto baru yg diupload
  List<String> _buktiFotoLama = []; // url foto lama yg sudah ada
  String? _selectedKategori;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  LatLng? _lokasi;
  GoogleMapController? _mapController;
  bool _gunakanLokasiSekarang = true;
  int _miniMapId = 0;
  int _uploadFotoKey = 0;

  final List<String> _kategoriMasalah = [
    'Infrastruktur',
    'Keamanan',
    'Kebersihan',
    'Sosial',
    'Lain-lain',
  ];

  final supabase = Supabase.instance.client;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final laporan = widget.laporan;

    _judulController.text = laporan['judul'] ?? '';
    _deskripsiController.text = laporan['deskripsi'] ?? '';
    _selectedKategori = laporan['kategori'];
    _alamatManualController.text = laporan['alamat_manual'] ?? '';
    final waktuKejadian = laporan['waktu_kejadian'];
    if (waktuKejadian != null) {
      final dt = DateTime.tryParse(waktuKejadian);
      if (dt != null) {
        _selectedDate = dt;
        _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
    }

    final lat = laporan['koordinat_lat'];
    final lng = laporan['koordinat_lng'];
    if (lat != null && lng != null) {
      _lokasi = LatLng(lat, lng);
      _gunakanLokasiSekarang = true;
    } else {
      _gunakanLokasiSekarang = false;
    }

    final fotoUrlsDynamic = laporan['foto_urls'] as List<dynamic>? ?? [];
    _buktiFotoLama = fotoUrlsDynamic.map((e) => e.toString()).toList();

    _miniMapId++;
    _uploadFotoKey++;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  void _setGunakanLokasiSekarang(bool val) {
    setState(() {
      _gunakanLokasiSekarang = val;
      if (!_gunakanLokasiSekarang) {
        _lokasi = null; // reset koordinat kalau pilih manual alamat
      } else {
        _getLokasiSekarang(); // kalau balik ke otomatis, ambil lokasi sekarang lagi
      }
    });
  }

  Future<void> _getLokasiSekarang() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _lokasi = LatLng(position.latitude, position.longitude);
      _miniMapId++;
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

  void _bukaPetaModal() {
    if (_lokasi == null) {
      _showToast('Lokasi belum tersedia', error: true);
      return;
    }

    LatLng lokasiSementara = _lokasi!;
    GoogleMapController? modalMapController;

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
                            target: lokasiSementara,
                            zoom: 15,
                          ),
                          onMapCreated: (controller) {
                            modalMapController = controller;
                          },
                          onCameraMove: (position) {
                            lokasiSementara = position.target;
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
                              lokasiSementara = newPosition;
                            });
                            if (modalMapController != null) {
                              modalMapController!.animateCamera(
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
                              _lokasi = lokasiSementara;
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

  Future<void> _uploadFoto() async {
    // Menggunakan image_picker
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 70);
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        _buktiFotoBaru.addAll(picked);
      });
    }
  }

  void _removeFotoLama(int index) {
    setState(() {
      _buktiFotoLama.removeAt(index);
    });
  }

  void _removeFotoBaru(int index) {
    setState(() {
      _buktiFotoBaru.removeAt(index);
    });
  }

  Future<void> _updateLaporan() async {
    final judul = _judulController.text.trim();
    final deskripsi = _deskripsiController.text.trim();
    final alamatManual = _alamatManualController.text.trim();

    // Validasi form (sederhana)
    if (judul.isEmpty) {
      _showToast('Judul laporan tidak boleh kosong', error: true);
      return;
    }
    if (_selectedKategori == null) {
      _showToast('Kategori masalah harus dipilih', error: true);
      return;
    }
    if (deskripsi.isEmpty) {
      _showToast('Deskripsi masalah tidak boleh kosong', error: true);
      return;
    }
    if (_gunakanLokasiSekarang && _lokasi == null) {
      _showToast('Lokasi otomatis belum terdeteksi, coba lagi', error: true);
      return;
    }
    if (!_gunakanLokasiSekarang && alamatManual.isEmpty) {
      _showToast('Alamat lokasi kejadian harus diisi secara manual', error: true);
      return;
    }
    if (_buktiFotoLama.isEmpty && _buktiFotoBaru.isEmpty) {
      _showToast('Foto bukti harus diupload minimal satu', error: true);
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      _showToast('Tanggal dan waktu kejadian harus diisi', error: true);
      return;
    }

    setState(() => _loading = true);

    try {
      // Upload foto baru ke Supabase Storage
      List<String> fotoUrlsBaru = [];
      for (var foto in _buktiFotoBaru) {
        final fileBytes = await foto.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${foto.name}';

        await supabase.storage.from('laporanfoto').uploadBinary(fileName, fileBytes);
        final publicUrl = supabase.storage.from('laporanfoto').getPublicUrl(fileName);
        fotoUrlsBaru.add(publicUrl);
      }

      // Gabungkan foto lama yang tidak dihapus + foto baru
      final fotoFinal = [..._buktiFotoLama, ...fotoUrlsBaru];

      // Update ke tabel laporan
      final laporanId = widget.laporan['id'];
      final updateResponse = await supabase
          .from('laporan')
          .update({
            'judul': judul,
            'kategori': _selectedKategori,
            'deskripsi': deskripsi,
            'koordinat_lat': _gunakanLokasiSekarang ? _lokasi?.latitude : null,
            'koordinat_lng': _gunakanLokasiSekarang ? _lokasi?.longitude : null,
            'alamat_manual': !_gunakanLokasiSekarang && alamatManual.isNotEmpty ? alamatManual : null,
            'waktu_kejadian': DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            ).toIso8601String(),
            'foto_urls': fotoFinal,
          })
          .eq('id', laporanId)
          .select();

      if (updateResponse == null || (updateResponse is List && updateResponse.isEmpty)) {
        throw Exception('Update gagal, data tidak ditemukan.');
      }

      _showToast('Laporan berhasil diperbarui!');
      Navigator.pop(context, true);
    } catch (e) {
      _showToast('Gagal update laporan: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Laporan'),
        backgroundColor: const Color.fromRGBO(104, 159, 153, 1),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          onChanged: (val) {
                            if (val != null) _setGunakanLokasiSekarang(val);
                          },
                        ),
                        const Text('Gunakan Lokasi Sekarang'),
                        Radio<bool>(
                          value: false,
                          groupValue: _gunakanLokasiSekarang,
                          onChanged: (val) {
                            if (val != null) _setGunakanLokasiSekarang(val);
                          },
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Tampilkan foto lama dengan tombol hapus
                        for (int i = 0; i < _buktiFotoLama.length; i++)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _buktiFotoLama[i],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => _removeFotoLama(i),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // Tampilkan foto baru dengan tombol hapus
                        for (int i = 0; i < _buktiFotoBaru.length; i++)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_buktiFotoBaru[i].path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => _removeFotoBaru(i),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // Tombol tambah foto baru
                        GestureDetector(
                          onTap: _uploadFoto,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _updateLaporan,
                          child: const Text('Simpan Perubahan',
                          style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue
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
}
