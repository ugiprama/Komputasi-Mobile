import 'package:flutter/material.dart';
import '../helpers/status_helpers.dart';

class LaporanHeader extends StatelessWidget {
  final String id;
  final String judul;
  final String status;
  final String kategori;
  final String? waktuKejadian;
  final String? createdAt;

  final VoidCallback onCopyId;
  final VoidCallback onShare;

  const LaporanHeader({
    super.key,
    required this.id,
    required this.judul,
    required this.status,
    required this.kategori,
    this.waktuKejadian,
    this.createdAt,
    required this.onCopyId,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: statusColor(status).withOpacity(0.15),
            child: Icon(statusIcon(status), color: statusColor(status)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Chip(
                      label: Text(status),
                      labelStyle: TextStyle(
                        color: statusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: statusColor(status).withOpacity(0.12),
                      avatar: Icon(statusIcon(status), size: 18, color: statusColor(status)),
                    ),
                    Chip(
                      label: Text(kategori),
                      backgroundColor: Colors.grey[100],
                    ),
                    Chip(
                      label: Text('ID: ${id.substring(0, 8)}...'),
                      backgroundColor: Colors.grey[100],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(child:
                    Text(
                      waktuKejadian != null ? formatRelative(waktuKejadian) : '-',
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    ),
                  ],
                ),
                if (createdAt != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 22), // align with clock icon above
                      Text(
                        'Kejadian: ${formatAbsolute(createdAt)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
