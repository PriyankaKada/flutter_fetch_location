import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'map_screen.dart';
import 'predefined_route_screen.dart'; // Import the new screen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // Predefined 6 points
  final List<LatLng> _predefinedPoints = const [
    LatLng(19.0760, 72.8777),   // Chhatrapati Shivaji Maharaj Terminus (CSMT)
    LatLng(19.0176, 72.8561),   // Gateway of India
    LatLng(19.0330, 72.8656),   // Marine Drive
    LatLng(19.2143, 72.9781),   // Sanjay Gandhi National Park
    LatLng(19.1183, 72.8467),   // Bandra-Worli Sea Link
    LatLng(18.9409, 72.8345),   // Elephanta Caves
  ];

  Future<void> _handleTripStart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      WidgetsFlutterBinding.ensureInitialized();
      final status = await Permission.location.status;

      if (!status.isGranted) {
        final result = await Permission.location.request();
        if (!result.isGranted) {
          setState(() {
            _errorMessage = 'Location permission is required to start the trip';
          });
          return;
        }
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MapScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start trip: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPredefinedRoute() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PredefinedRouteScreen(
          routePoints: _predefinedPoints,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Tracker'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _handleTripStart,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  minimumSize: const Size(200, 50),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Start Trip',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showPredefinedRoute,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Show Predefined Route',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: openAppSettings,
                  child: const Text('Open App Settings'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}