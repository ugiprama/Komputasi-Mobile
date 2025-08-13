import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

/// Buka Google Maps dengan koordinat atau alamat
Future<void> openMaps({
  required BuildContext context,
  double? lat,
  double? lng,
  String? alamat,
}) async {
  String url;
  if (lat != null && lng != null) {
    url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  } else if (alamat != null && alamat.isNotEmpty) {
    url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(alamat)}';
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lokasi tidak tersedia')),
    );
    return;
  }
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal membuka Maps')),
    );
  }
}

/// Salin teks ke clipboard dan tampilkan snackbar
Future<void> shareText(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Teks disalin — siap ditempel di mana saja')),
  );
}
