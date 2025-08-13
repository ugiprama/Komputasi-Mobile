import 'package:flutter/material.dart';
import 'package:applaporwarga/views/admin/admin_laporan/widgets/map_preview.dart';
// import 'package:applaporwarga/views/admin/admin_laporan/widgets/map_fullscreen.dart';

class LaporanLocation extends StatelessWidget {
  final String alamatManual;
  final double? lat;
  final double? lng;

  const LaporanLocation({
    super.key,
    required this.alamatManual,
    this.lat,
    this.lng,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("Lat: $lat, Lng: $lng"); // debug koordinat
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (alamatManual.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place, color: Colors.red, size: 20),
              const SizedBox(width: 6),
              Expanded(child: Text(alamatManual)),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (lat != null && lng != null)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenMap(
                    lat: lat!,
                    lng: lng!,
                    alamat: alamatManual,
                  ),
                ),
              );
            },
            child: MapPreview(
              lat: lat!,
              lng: lng!,
              alamat: alamatManual,
            ),
          ),
      ],
    );
  }
}
