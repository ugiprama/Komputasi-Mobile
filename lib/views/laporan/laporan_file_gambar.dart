import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadFotoMultiWidget extends StatefulWidget {
  final List<XFile> fotoSebelumnya;
  final Function(List<XFile>) onFotoDiubah;

  const UploadFotoMultiWidget({
    Key? key,
    required this.fotoSebelumnya,
    required this.onFotoDiubah,
  }) : super(key: key);

  @override
  State<UploadFotoMultiWidget> createState() => _UploadFotoMultiWidgetState();
}

class _UploadFotoMultiWidgetState extends State<UploadFotoMultiWidget> {
  List<XFile> _fotoList = [];

  @override
  void initState() {
    super.initState();
    _fotoList = List.from(widget.fotoSebelumnya);
  }

  Future<void> _ambilFoto(ImageSource source) async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: source);
    if (foto != null) {
      setState(() {
        _fotoList.add(foto);
      });
      widget.onFotoDiubah(_fotoList);
    }
  }

  void _hapusFoto(int index) {
    setState(() {
      _fotoList.removeAt(index);
    });
    widget.onFotoDiubah(_fotoList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _fotoList.asMap().entries.map((entry) {
            int index = entry.key;
            XFile file = entry.value;
            return Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(file.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: -10,
                  top: -10,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _hapusFoto(index),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _ambilFoto(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Ambil Foto"),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _ambilFoto(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Dari Galeri"),
            ),
          ],
        ),
      ],
    );
  }
}
