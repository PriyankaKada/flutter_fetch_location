import 'dart:convert';
import 'package:flutter/services.dart';
import 'user_location.dart';

class UserLocationService {
  Future<List<UserLocation>> getOtherUsersLocations() async {
    // In a real app, this would be an API call
    // For now, we'll load from the mock JSON file
    final jsonString = await rootBundle.loadString('assets/mock_users.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    
    return jsonList.map((json) => UserLocation.fromJson(json)).toList();
  }
}