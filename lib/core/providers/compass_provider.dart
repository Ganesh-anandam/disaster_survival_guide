// lib/core/providers/compass_provider.dart
// ============================================================
// Provider for offline GPS-based safe zone compass navigation.
// Uses geolocator for live location and calculates bearing + distance.
// ============================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../database/database_helper.dart';
import '../models/first_aid_model.dart';

class CompassProvider extends ChangeNotifier {
  List<SafeZone> _safeZones = [];
  SafeZone? _selectedZone;
  Position? _currentPosition;
  double? _bearing; // degrees from North (0-360)
  double? _distanceMeters;
  bool _isLoading = false;
  String _errorMessage = '';
  StreamSubscription<Position>? _positionSubscription;

  List<SafeZone> get safeZones => _safeZones;
  SafeZone? get selectedZone => _selectedZone;
  Position? get currentPosition => _currentPosition;
  double? get bearing => _bearing;
  double? get distanceMeters => _distanceMeters;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasLocation => _currentPosition != null;

  String get distanceLabel {
    if (_distanceMeters == null) return '--';
    if (_distanceMeters! < 1000) {
      return '${_distanceMeters!.toStringAsFixed(0)} m';
    }
    return '${(_distanceMeters! / 1000).toStringAsFixed(1)} km';
  }

  Future<void> loadSafeZones() async {
    _isLoading = true;
    notifyListeners();
    try {
      _safeZones = await DatabaseHelper.getSafeZones();
      if (_safeZones.isNotEmpty) {
        _selectedZone = _safeZones.first;
      }
    } catch (e) {
      _errorMessage = 'Error loading safe zones';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _errorMessage =
          'Location services are disabled. Enable GPS to use safe route.';
      notifyListeners();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      _errorMessage = 'Location permission denied. Enable in settings.';
      notifyListeners();
      return;
    }

    await _positionSubscription?.cancel();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // update every 5 meters
      ),
    ).listen(
      (Position position) {
        _currentPosition = position;
        _calculateBearingAndDistance();
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'GPS error. Make sure GPS is enabled.';
        notifyListeners();
      },
    );
  }

  void selectZone(SafeZone zone) {
    _selectedZone = zone;
    _calculateBearingAndDistance();
    notifyListeners();
  }

  void _calculateBearingAndDistance() {
    if (_currentPosition == null || _selectedZone == null) return;

    final lat1 = _toRadians(_currentPosition!.latitude);
    final lon1 = _toRadians(_currentPosition!.longitude);
    final lat2 = _toRadians(_selectedZone!.latitude);
    final lon2 = _toRadians(_selectedZone!.longitude);

    // Bearing formula
    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    _bearing = (_toDegrees(math.atan2(y, x)) + 360) % 360;

    // Haversine distance formula
    _distanceMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _selectedZone!.latitude,
      _selectedZone!.longitude,
    );
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
  double _toDegrees(double radians) => radians * 180 / math.pi;

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
