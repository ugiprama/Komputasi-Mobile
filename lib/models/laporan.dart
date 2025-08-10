class Laporan {
  final String id;
  final String userId;
  final String judul;
  final String kategori;
  final String? deskripsi;
  final String? alamat;
  final double? koordinatLat;
  final double? koordinatLng;
  final List<String> fotoUrls;
  final String status;
  final DateTime? waktuKejadian;
  final DateTime createdAt;

  Laporan({
    required this.id,
    required this.userId,
    required this.judul,
    required this.kategori,
    this.deskripsi,
    this.alamat,
    this.koordinatLat,
    this.koordinatLng,
    required this.fotoUrls,
    required this.status,
    this.waktuKejadian,
    required this.createdAt,
  });

  factory Laporan.fromMap(Map<String, dynamic> map) {
    return Laporan(
      id: map['id'],
      userId: map['user_id'],
      judul: map['judul'],
      kategori: map['kategori'],
      deskripsi: map['deskripsi'],
      alamat: map['alamat'],
      koordinatLat: map['koordinat_lat'],
      koordinatLng: map['koordinat_lng'],
      fotoUrls: List<String>.from(map['foto_urls'] ?? []),
      status: map['status'],
      waktuKejadian: map['waktu_kejadian'] != null
          ? DateTime.parse(map['waktu_kejadian'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'judul': judul,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'alamat': alamat,
      'koordinat_lat': koordinatLat,
      'koordinat_lng': koordinatLng,
      'foto_urls': fotoUrls,
      'status': status,
      'waktu_kejadian': waktuKejadian?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
