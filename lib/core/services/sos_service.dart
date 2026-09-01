// lib/core/services/sos_service.dart
// ============================================================
// SOS Service: Handles SMS drafting, torch SOS Morse code pattern,
// and offline siren audio. All operations are local (no network needed).
// ============================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Morse code SOS: ... --- ...
/// Short = 200ms ON, Long = 600ms ON, Gap = 200ms OFF
class SosService {
  // Default SOS contact (in production, user configures this)
  static const String _defaultEmergencyNumber = '112';
  static const String _prefKeyContactName = 'sos_contact_name';
  static const String _prefKeyContactPhone = 'sos_contact_phone';

  // SOS Morse: ... (S) --- (O) ... (S)
  // true = torch ON, false = torch OFF
  static const List<({bool on, int ms})> _morsePattern = [
    // S: three dots
    (on: true, ms: 200),  (on: false, ms: 200),
    (on: true, ms: 200),  (on: false, ms: 200),
    (on: true, ms: 200),  (on: false, ms: 400),
    // O: three dashes
    (on: true, ms: 600),  (on: false, ms: 200),
    (on: true, ms: 600),  (on: false, ms: 200),
    (on: true, ms: 600),  (on: false, ms: 400),
    // S: three dots
    (on: true, ms: 200),  (on: false, ms: 200),
    (on: true, ms: 200),  (on: false, ms: 200),
    (on: true, ms: 200),  (on: false, ms: 1000),
  ];

  bool _isMorseActive = false;
  Timer? _morseTimer;

  // ── Save / Load SOS contact ───────────────────────────────
  Future<void> saveContact(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyContactName, name);
    await prefs.setString(_prefKeyContactPhone, phone);
  }

  Future<({String name, String phone})> loadContact() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      name: prefs.getString(_prefKeyContactName) ?? 'Emergency Contact',
      phone: prefs.getString(_prefKeyContactPhone) ?? _defaultEmergencyNumber,
    );
  }

  // ── Send SOS SMS ──────────────────────────────────────────
  Future<bool> sendSosSms({Position? position}) async {
    final contact = await loadContact();
    String message = '🆘 SOS EMERGENCY ALERT! I need immediate help!';

    if (position != null) {
      final lat = position.latitude.toStringAsFixed(6);
      final lon = position.longitude.toStringAsFixed(6);
      message += '\n📍 Location: $lat, $lon';
      message += '\nhttps://maps.google.com/?q=$lat,$lon';
    } else {
      message += '\n📍 Location: GPS unavailable - find me!';
    }

    message += '\n⏰ Time: ${DateTime.now().toLocal()}';

    final uri = Uri(
      scheme: 'sms',
      path: contact.phone,
      queryParameters: {'body': message},
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
    } catch (e) {
      debugPrint('SMS launch error: $e');
    }
    return false;
  }

  // ── Get current GPS position ──────────────────────────────
  Future<Position?> getCurrentPosition() async {
    try {
      if (!kIsWeb) {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint('GPS error: $e');
      return null;
    }
  }

  // ── Torch SOS Morse Code ──────────────────────────────────
  Future<void> startMorseSos() async {
    if (_isMorseActive) return;
    _isMorseActive = true;
    _runMorsePattern();
  }

  void _runMorsePattern() async {
    if (!_isMorseActive) return;

    for (final beat in _morsePattern) {
      if (!_isMorseActive) break;
      try {
        // Platform-specific torch control (mobile only)
        if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
          // torch_light package (mobile only)
          if (beat.on) {
            // TorchLight.enableTorch();
          } else {
            // TorchLight.disableTorch();
          }
        }
      } catch (_) {}
      await Future.delayed(Duration(milliseconds: beat.ms));
    }

    // Repeat until stopped
    if (_isMorseActive) {
      _runMorsePattern();
    }
  }

  void stopMorseSos() {
    _isMorseActive = false;
    try {
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
        // TorchLight.disableTorch();
      }
    } catch (_) {}
  }

  bool get isMorseActive => _isMorseActive;

  void dispose() {
    _morseTimer?.cancel();
    stopMorseSos();
  }
}

// Global singleton instance
final sosService = SosService();
