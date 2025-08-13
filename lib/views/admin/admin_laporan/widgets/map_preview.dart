import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPreview extends StatelessWidget {
  final double lat;
  final double lng;
  final String alamat;

  const MapPreview({
    required this.lat,
    required this.lng,
    this.alamat = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, lng),
              zoom: 15,
            ),
            markers: {
              Marker(markerId: MarkerId('laporan'), position: LatLng(lat, lng)),
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            gestureRecognizers: {}, // biar tidak bisa digeser di preview
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenMap(
                        lat: lat,
                        lng: lng,
                        alamat: alamat,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class FullScreenMap extends StatefulWidget {
  final double lat;
  final double lng;
  final String alamat;

  const FullScreenMap({
    required this.lat,
    required this.lng,
    this.alamat = '',
    super.key,
  });

  @override
  State<FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  MapType _currentMapType = MapType.normal;

  void _changeMapType(MapType type) {
    setState(() {
      _currentMapType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.lat, widget.lng),
              zoom: 17,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('laporan'),
                position: LatLng(widget.lat, widget.lng),
                infoWindow: InfoWindow(title: widget.alamat),
              ),
            },
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),

          // Tombol Close
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: 16,
            child: PopupMenuButton<MapType>(
              icon: const Icon(Icons.layers, color: Colors.black),
              onSelected: _changeMapType,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: MapType.normal,
                  child: Text("Normal"),
                ),
                const PopupMenuItem(
                  value: MapType.hybrid,
                  child: Text("Hybrid (Satelit + Jalan)"),
                ),
                const PopupMenuItem(
                  value: MapType.terrain,
                  child: Text("Terrain"),
                ),
                const PopupMenuItem(
                  value: MapType.satellite,
                  child: Text("Satellite"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

