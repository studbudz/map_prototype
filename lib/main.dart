import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  final LatLng _defaultLocation = LatLng(1.2878, 103.8666); // ✅ Default Location

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
        options: MapOptions(
          initialCameraPosition: CameraPosition(
            center: _defaultLocation, // ✅ Corrected center
            zoom: 11, // ✅ Corrected zoom
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'dev.fleaflet.flutter_map.example', // ✅ Corrected
          ),
        ],
      ),
    );
  }
}
