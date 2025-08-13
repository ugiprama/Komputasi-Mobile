import 'package:flutter/material.dart';
import '../helpers/status_helpers.dart';

class StatusUpdateSheet extends StatefulWidget {
  final String currentStatus;
  final Function(String selectedStatus, String? note) onSave;

  const StatusUpdateSheet({
    super.key,
    required this.currentStatus,
    required this.onSave,
  });

  @override
  State<StatusUpdateSheet> createState() => _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends State<StatusUpdateSheet> {
  late String selected;
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selected = widget.currentStatus;
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Ubah Status Laporan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final s in ['Proses', 'Pengerjaan', 'Selesai'])
                ChoiceChip(
                  selected: selected == s,
                  label: Text(s),
                  onSelected: (_) => setState(() => selected = s),
                  avatar: Icon(
                    statusIcon(s),
                    size: 18,
                    color: selected == s ? Colors.white : statusColor(s),
                  ),
                  selectedColor: statusColor(s),
                  labelStyle: TextStyle(
                    color: selected == s ? Colors.white : statusColor(s),
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: statusColor(s).withOpacity(0.12),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Catatan untuk pelapor (opsional)",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Simpan"),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onSave(
                  selected,
                  noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
