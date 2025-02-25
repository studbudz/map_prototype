import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LatLng _defaultLocation = LatLng(1.2878, 103.8666);
  late List<Marker> markers;

  @override
  void initState() {
    super.initState();
    markers = createRandomMarkers(
      100,
    ); // Change the number to create more or fewer markers
  }

  Marker createMarker(LatLng latLng) {
    return Marker(
      point: latLng,
      width: 80,
      height: 80,
      child: const Icon(Icons.location_on, size: 40.0, color: Colors.red),
    );
  }

  List<Marker> createRandomMarkers(int count) {
    final Random random = Random();
    List<Marker> randomMarkers = [];

    for (int i = 0; i < count; i++) {
      // Generate random coordinates for latitude and longitude
      double lat =
          random.nextDouble() * 180 - 90; // Random latitude between -90 and 90
      double lng =
          random.nextDouble() * 360 -
          180; // Random longitude between -180 and 180
      randomMarkers.add(createMarker(LatLng(lat, lng)));
    }

    return randomMarkers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OpenStreetMap in Flutter',
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: FlutterMap(
        mapController: MapController(),
        options: MapOptions(),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            // Plenty of other options available!
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(30, 40),
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  size: 40.0,
                  color: Colors.red,
                ),
              ),
              ...markers,
            ],
          ),
        ],
      ),
    );
  }
}
