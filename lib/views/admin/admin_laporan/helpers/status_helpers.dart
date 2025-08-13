import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Inisialisasi locale untuk timeago Indonesia
void initTimeagoLocale() {
  timeago.setLocaleMessages('id', timeago.IdMessages());
}

/// Format waktu relatif seperti "3 menit lalu", "Kemarin, 14:35"
String formatRelative(String? iso) {
  if (iso == null) return '-';
  try {
    final dt = DateTime.parse(iso).toLocal();
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return timeago.format(dt, locale: 'id');
    }
    if (DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1))
        .isAtSameMomentAs(DateTime(dt.year, dt.month, dt.day))) {
      return "Kemarin, ${DateFormat('HH:mm', 'id').format(dt)}";
    }
    return DateFormat("d MMM yyyy, HH:mm", 'id').format(dt);
  } catch (_) {
    return iso!;
  }
}

/// Format waktu absolut seperti "Senin, 12 Agu 2024 • 14:35"
String formatAbsolute(String? iso) {
  if (iso == null) return '-';
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat("EEEE, d MMM yyyy • HH:mm", 'id').format(dt);
  } catch (_) {
    return iso!;
  }
}

/// Warna status utama
Color statusColor(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'proses':
      return Colors.blueAccent;
    case 'pengerjaan':
      return Colors.orangeAccent;
    case 'selesai':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

/// Gradient untuk tampilan modern
Gradient statusGradient(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'proses':
      return LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]);
    case 'pengerjaan':
      return LinearGradient(colors: [Colors.orange, Colors.deepOrange]);
    case 'selesai':
      return LinearGradient(colors: [Colors.green, Colors.teal]);
    default:
      return LinearGradient(colors: [Colors.grey, Colors.black26]);
  }
}

/// Ikon status
IconData statusIcon(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'proses':
      return Icons.hourglass_bottom;
    case 'pengerjaan':
      return Icons.engineering;
    case 'selesai':
      return Icons.check_circle;
    default:
      return Icons.info;
  }
}

/// Badge status dengan animasi & gradient
Widget statusBadge(String status) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      gradient: statusGradient(status),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: statusColor(status).withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(statusIcon(status), size: 18, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          status,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}
