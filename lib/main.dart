import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenStreetMap with Coordinates',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Location _location = Location();
  late WebSocketChannel _channel;
  LatLng _currentLocation = LatLng(0.0, 0.0);
  List<LatLng> _pins = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _connectToServer();
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if location services are enabled
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if we have permission to access location
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get the current location
    LocationData locationData = await _location.getLocation();
    setState(() {
      _currentLocation = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
    });

    // Send the coordinates to the server
    _sendCoordinatesToServer(locationData.latitude!, locationData.longitude!);
  }

  // Connect to the WebSocket server
  void _connectToServer() {
    _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080'));
    _channel.stream.listen((message) {
      var data = jsonDecode(message);
      if (data['type'] == 'coordinates') {
        // Handle received coordinates from other clients
        double latitude = data['latitude'];
        double longitude = data['longitude'];
        setState(() {
          _pins.add(LatLng(latitude, longitude));
        });
      }
    });
  }

  // Send coordinates to the server
  void _sendCoordinatesToServer(double latitude, double longitude) {
    var message = jsonEncode({
      'type': 'coordinates',
      'latitude': latitude,
      'longitude': longitude,
    });
    _channel.sink.add(message);
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OpenStreetMap with Coordinates")),
      body: FlutterMap(
        options: MapOptions(center: _currentLocation, zoom: 13.0),
        nonRotatedChildren: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              // Marker for the current location
              Marker(
                point: _currentLocation,
                builder:
                    (ctx) =>
                        Icon(Icons.location_on, color: Colors.blue, size: 40.0),
              ),
              // Markers for other coordinates received from the server
              for (var pin in _pins)
                Marker(
                  point: pin,
                  builder:
                      (ctx) => Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
