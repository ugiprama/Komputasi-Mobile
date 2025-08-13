import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'key_value_row.dart';

class LaporanReporter extends StatelessWidget {
  final String namaPelapor;
  final String emailPelapor;
  final String telpPelapor;

  const LaporanReporter({
    super.key,
    required this.namaPelapor,
    required this.emailPelapor,
    required this.telpPelapor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KeyValueRow(keyText: 'Nama', valueText: namaPelapor),
        if (emailPelapor.isNotEmpty) KeyValueRow(keyText: 'Email', valueText: emailPelapor),
        if (telpPelapor.isNotEmpty) KeyValueRow(keyText: 'Telepon', valueText: telpPelapor),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            if (emailPelapor.isNotEmpty)
              OutlinedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Email'),
                onPressed: () => launchUrl(Uri.parse('mailto:$emailPelapor')),
              ),
            if (telpPelapor.isNotEmpty)
              OutlinedButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text('Telepon'),
                onPressed: () => launchUrl(Uri.parse('tel:$telpPelapor')),
              ),
          ],
        ),
      ],
    );
  }
}
