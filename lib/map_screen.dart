import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'location_repository.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  Position? _currentPosition;
  Timer? _locationTimer;
  final LocationRepository _locationRepo = LocationRepository();

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    // Get initial location
    _getCurrentLocation();
    
    // Set up timer to get location every 3 minutes
    _locationTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      
      setState(() {
        _currentPosition = position;
        _markers.add(
          Marker(
            markerId: MarkerId(position.timestamp.toString()),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(
              title: '${position.latitude}, ${position.longitude}',
              snippet: 'Recorded at ${position.timestamp}',
            ),
          ),
        );
      });
      
      // Move camera to new position
      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
      
      // Save to local and remote databases
      await _locationRepo.saveLocation(position);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip in Progress')),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0), // Default, will update when we get location
          zoom: 15,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _getCurrentLocation(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}