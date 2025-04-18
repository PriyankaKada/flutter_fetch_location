import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'location_repository.dart';
import 'user_location.dart';
import 'user_location_service.dart';

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
  final UserLocationService _userLocationService = UserLocationService();
  Timer? _usersUpdateTimer;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _startUsersUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _usersUpdateTimer?.cancel();
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

  void _startUsersUpdates() {
    // Get initial users data
    _getOtherUsersLocations();

    // Set up timer to get users data every 3 minutes
    _usersUpdateTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _getOtherUsersLocations();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        _currentPosition = position;
        _updateCurrentUserMarker(position);
      });

      // Move camera to new position
      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),  // This closes both the newLatLng and animateCamera calls
      );

    // Save to local and remote databases
          await _locationRepo.saveLocation(position);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _getOtherUsersLocations() async {
    try {
      final users = await _userLocationService.getOtherUsersLocations();

      setState(() {
        // Remove all markers except the current user's marker
        _markers.removeWhere((marker) => !marker.markerId.value.startsWith('current_'));

        // Add markers for other users
        for (final user in users) {
          _markers.add(
            Marker(
              markerId: MarkerId('user_${user.userId}'),
              position: user.toLatLng(),
              infoWindow: InfoWindow(
                title: user.username,
                snippet: '${user.latitude}, ${user.longitude}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );
        }
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting other users: $e')),
      );
    }
  }

  void _updateCurrentUserMarker(Position position) {
    // Remove previous current user marker if exists
    _markers.removeWhere((marker) => marker.markerId.value.startsWith('current_'));

    // Add new current user marker
    _markers.add(
      Marker(
        markerId: const MarkerId('current_user'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(
          title: 'You',
          snippet: '${position.latitude}, ${position.longitude}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _getCurrentLocation(),
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _getOtherUsersLocations(),
            child: const Icon(Icons.people),
          ),
        ],
      ),
    );
  }
}