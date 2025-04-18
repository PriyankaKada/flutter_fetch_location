import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocationRepository {
  static const String _remoteUrl = 'YOUR_REMOTE_SERVER_ENDPOINT';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'locations.db');
    
    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE locations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL,
            longitude REAL,
            timestamp INTEGER,
            accuracy REAL,
            altitude REAL,
            speed REAL,
            speed_accuracy REAL,
            heading REAL
          )
        ''');
      },
    );
  }

  Future<void> saveLocation(Position position) async {
    // Save to local database
    final db = await database;
    await db.insert('locations', {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': position.timestamp?.millisecondsSinceEpoch,
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'speed': position.speed,
      'speed_accuracy': position.speedAccuracy,
      'heading': position.heading,
    });
    
    // Save to remote server
    try {
      await http.post(
        Uri.parse(_remoteUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': position.timestamp?.toIso8601String(),
          'accuracy': position.accuracy,
          'altitude': position.altitude,
          'speed': position.speed,
          'speed_accuracy': position.speedAccuracy,
          'heading': position.heading,
        }),
      );
    } catch (e) {
      // Handle error (could implement retry logic here)
      print('Error saving to remote: $e');
    }
  }
}