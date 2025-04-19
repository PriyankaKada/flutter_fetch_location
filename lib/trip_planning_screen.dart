import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;

class TripPlanningScreen extends StatefulWidget {
  const TripPlanningScreen({super.key});

  @override
  State<TripPlanningScreen> createState() => _TripPlanningScreenState();
}

class _TripPlanningScreenState extends State<TripPlanningScreen> {
  late final MapController _mapController;
  List<latlong2.LatLng> _routePoints = [];
  bool _showRoute = false;

  final List<latlong2.LatLng> _predefinedPoints = const [
    latlong2.LatLng(51.5, -0.09),
    latlong2.LatLng(51.51, -0.1),
    latlong2.LatLng(51.52, -0.08),
    latlong2.LatLng(51.49, -0.07),
    latlong2.LatLng(51.53, -0.11),
    latlong2.LatLng(51.48, -0.12),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _drawPredefinedRoute() {
    setState(() {
      _routePoints = List.from(_predefinedPoints);
      _showRoute = true;

      double avgLat = _routePoints.map((p) => p.latitude).reduce((a, b) => a + b) / _routePoints.length;
      double avgLng = _routePoints.map((p) => p.longitude).reduce((a, b) => a + b) / _routePoints.length;

      _mapController.move(latlong2.LatLng(avgLat, avgLng), 12.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Planner'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: const latlong2.LatLng(51.5, -0.09),  // Changed from initialCenter to center
                zoom: 12.0,  // Changed from initialZoom to zoom
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                if (_showRoute)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: Colors.blue.withOpacity(0.7),
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                if (_showRoute)
                  MarkerLayer(
                    markers: _routePoints.asMap().entries.map((entry) {
                      final index = entry.key;
                      final point = entry.value;
                      return Marker(
                        point: point,
                        builder: (ctx) => Icon(
                          index == 0 ? Icons.location_on :
                          index == _routePoints.length - 1 ? Icons.flag : Icons.location_pin,
                          color: index == 0 ? Colors.green :
                          index == _routePoints.length - 1 ? Colors.red : Colors.blue,
                          size: 30,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _drawPredefinedRoute,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Plan Trip',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}