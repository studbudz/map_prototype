import 'dart:io';
import 'dart:convert';

void main() async {
  // Start the WebSocket server on port 8080
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('WebSocket Server running on ws://${server.address.address}:${server.port}');

  final List<WebSocket> clients = [];

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);
      clients.add(socket);
      print('New client connected. Total clients: ${clients.length}');

      // Listen for incoming messages
      socket.listen((data) {
        try {
          var message = jsonDecode(data);
          if (message['type'] == 'coordinates') {
            double latitude = message['latitude'];
            double longitude = message['longitude'];

            print('Received coordinates: Lat: $latitude, Lng: $longitude');

            // Broadcast to all connected clients
            for (var client in clients) {
              if (client != socket) {
                client.add(jsonEncode({
                  'type': 'coordinates',
                  'latitude': latitude,
                  'longitude': longitude,
                }));
              }
            }
          }
        } catch (e) {
          print('Error processing message: $e');
        }
      });

      // Handle client disconnection
      socket.done.then((_) {
        clients.remove(socket);
        print('Client disconnected. Total clients: ${clients.length}');
      });
    } else {
      request.response.statusCode = HttpStatus.forbidden;
      request.response.close();
    }
  }
}
