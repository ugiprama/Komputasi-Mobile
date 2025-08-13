import 'package:flutter/material.dart';

class LaporanGallery extends StatelessWidget {
  final List<String> fotoUrls;
  final String laporanId;

  const LaporanGallery({
    super.key,
    required this.fotoUrls,
    required this.laporanId,
  });

  @override
  Widget build(BuildContext context) {
    if (fotoUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Bukti',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.92),
            itemCount: fotoUrls.length,
            itemBuilder: (context, i) {
              final url = fotoUrls[i];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'foto-$i-$laporanId',
                        child: InteractiveViewer(
                          child: Image.network(url, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${i + 1}/${fotoUrls.length}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
