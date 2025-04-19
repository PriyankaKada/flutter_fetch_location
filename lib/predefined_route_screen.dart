import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PredefinedRouteScreen extends StatefulWidget {
  final List<LatLng> routePoints;

  const PredefinedRouteScreen({
    super.key,
    required this.routePoints,
  });

  @override
  State<PredefinedRouteScreen> createState() => _PredefinedRouteScreenState();
}

class _PredefinedRouteScreenState extends State<PredefinedRouteScreen> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final double _proximityThreshold = 10.0; // Meters

  void _checkPointOnLine() {
    try {
      final double lat = double.parse(_latController.text);
      final double lng = double.parse(_lngController.text);
      final LatLng testPoint = LatLng(lat, lng);

      bool isOnLine = _isPointNearPolyline(testPoint, widget.routePoints);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isOnLine ? 'Point is on the route!' : 'Point is NOT on the route.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coordinates!')),
      );
    }
  }

  bool _isPointNearPolyline(LatLng point, List<LatLng> polyline) {
    final Distance distance = const Distance();
    for (int i = 0; i < polyline.length - 1; i++) {
      final LatLng start = polyline[i];
      final LatLng end = polyline[i + 1];
      final double distToSegment = _distanceToLineSegment(point, start, end);
      if (distToSegment <= _proximityThreshold) {
        return true;
      }
    }
    return false;
  }
  /// Computes the shortest distance from [point] to the line segment [start]-[end].
  double _distanceToLineSegment(LatLng point, LatLng start, LatLng end) {
    final Distance distance = const Distance();
    final double lineLength = distance(start, end);
    if (lineLength == 0) return distance(point, start); // start == end

    // Project point onto the line segment
    final double t = ((point.latitude - start.latitude) * (end.latitude - start.latitude) +
        ((point.longitude - start.longitude) * (end.longitude - start.longitude))) /
        (lineLength * lineLength);

    // Clamp projection to the segment
    final double clampedT = t.clamp(0.0, 1.0);
    final LatLng projectedPoint = LatLng(
      start.latitude + clampedT * (end.latitude - start.latitude),
      start.longitude + clampedT * (end.longitude - start.longitude),
    );

    return distance(point, projectedPoint);
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Predefined Route')),
      body: Column(
        children: [
          // Map
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: widget.routePoints.first,
                zoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.routePoints,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.routePoints.first,
                      builder: (ctx) => const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                    Marker(
                      point: widget.routePoints.last,
                      builder: (ctx) => const Icon(
                        Icons.flag,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Input Fields
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _latController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    hintText: 'e.g., 52.5200',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _lngController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    hintText: 'e.g., 13.4050',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _checkPointOnLine,
                  child: const Text('Check Point'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
