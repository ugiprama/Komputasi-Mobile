import 'package:flutter/material.dart';

class LaporanNotes extends StatelessWidget {
  final String catatan;

  const LaporanNotes({
    super.key,
    required this.catatan,
  });

  @override
  Widget build(BuildContext context) {
    if (catatan.trim().isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catatan Admin',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(catatan.trim()),
        const SizedBox(height: 16),
      ],
    );
  }
}
