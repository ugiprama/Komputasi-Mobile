import 'package:flutter/material.dart';

class LaporanPhotoViewerPage extends StatefulWidget {
  final List<String> fotoUrls;
  final int initialIndex;
  const LaporanPhotoViewerPage(
      {super.key, required this.fotoUrls, this.initialIndex = 0});

  @override
  State<LaporanPhotoViewerPage> createState() => _LaporanPhotoViewerPageState();
}

class _LaporanPhotoViewerPageState extends State<LaporanPhotoViewerPage> {
  late PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(0, widget.fotoUrls.length - 1);
    _pageController = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text('${_current + 1}/${widget.fotoUrls.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.fotoUrls.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (context, index) {
          final url = widget.fotoUrls[index];
          return Center(
            child: Hero(
              tag: 'laporan_foto_$index$url',
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return const CircularProgressIndicator();
                  },
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                      color: Colors.white, size: 80),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
