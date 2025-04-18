// user_location.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation {
  final String userId;
  final String username;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  UserLocation({
    required this.userId,
    required this.username,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      userId: json['userId'],
      username: json['username'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}