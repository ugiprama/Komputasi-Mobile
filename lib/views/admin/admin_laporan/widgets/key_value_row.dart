import 'package:flutter/material.dart';

class KeyValueRow extends StatelessWidget {
  final String keyText;
  final String valueText;

  const KeyValueRow({
    super.key,
    required this.keyText,
    required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              keyText,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(valueText.isEmpty ? '-' : valueText),
          ),
        ],
      ),
    );
  }
}
