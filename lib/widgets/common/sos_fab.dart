// lib/widgets/common/sos_fab.dart
// ============================================================
// Persistent SOS Floating Action Button.
// Long-press triggers: GPS capture → SMS draft.
// Short tap shows the SOS options sheet.
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/sos_service.dart';
import '../../core/theme/app_theme.dart';

class SosFab extends StatefulWidget {
  const SosFab({super.key});

  @override
  State<SosFab> createState() => _SosFabState();
}

class _SosFabState extends State<SosFab> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isSending = false;
  Timer? _longPressTimer;
  double _holdProgress = 0;
  bool _isHolding = false;
  Timer? _holdProgressTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _longPressTimer?.cancel();
    _holdProgressTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown() {
    setState(() {
      _isHolding = true;
      _holdProgress = 0;
    });

    // Animate hold progress over 1.5 seconds
    _holdProgressTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!_isHolding) {
        t.cancel();
        return;
      }
      setState(() => _holdProgress = (_holdProgress + (50 / 1500)).clamp(0, 1));
      if (_holdProgress >= 1) {
        t.cancel();
        _triggerSosSms();
      }
    });
  }

  void _onPointerUp() {
    setState(() {
      _isHolding = false;
      _holdProgress = 0;
    });
    _holdProgressTimer?.cancel();
  }

  Future<void> _triggerSosSms() async {
    HapticFeedback.heavyImpact();
    setState(() => _isSending = true);

    // Get GPS location (max 5s timeout)
    Position? position;
    try {
      position = await sosService.getCurrentPosition();
    } catch (_) {}

    final sent = await sosService.sendSosSms(position: position);

    if (mounted) {
      setState(() => _isSending = false);
      _showSosResult(sent);
    }
  }

  void _showSosResult(bool sent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sent ? '📤' : '❌', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              sent ? 'SOS Sent!' : 'Open SMS manually',
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSosSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🆘 EMERGENCY OPTIONS',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.emergency,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            _SosOption(
              emoji: '📱',
              label: 'HOLD 1.5s to Send SOS SMS',
              subtitle: 'Sends GPS location to your contact',
              color: AppColors.emergency,
            ),
            const SizedBox(height: 12),
            _SosOption(
              emoji: '🔦',
              label: 'Morse SOS Flash',
              subtitle: '...---... pattern via flashlight',
              color: AppColors.alert,
              onTap: () {
                Navigator.pop(ctx);
                sosService.startMorseSos();
                _showMorseDialog();
              },
            ),
            const SizedBox(height: 12),
            _SosOption(
              emoji: '📞',
              label: 'Call Emergency (112)',
              subtitle: 'Universal emergency number',
              color: AppColors.resource,
              onTap: () async {
                Navigator.pop(ctx);
                launchUrl(Uri(scheme: 'tel', path: '112'));
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showMorseDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔦', style: TextStyle(fontSize: 64))
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 200.ms)
                .fadeOut(delay: 200.ms, duration: 200.ms),
            const SizedBox(height: 16),
            const Text(
              'MORSE SOS ACTIVE\n...---...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.alert,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergency,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                sosService.stopMorseSos();
                Navigator.pop(ctx);
              },
              child: const Text(
                'STOP',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSosSheet,
      onLongPressStart: (_) => _onPointerDown(),
      onLongPressEnd: (_) => _onPointerUp(),
      onLongPressCancel: _onPointerUp,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.06);
          return Transform.scale(
            scale: _isSending ? 1.0 : scale,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emergency.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergency.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            // Hold progress circle
            if (_isHolding)
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: _holdProgress,
                  color: AppColors.alert,
                  backgroundColor: Colors.transparent,
                  strokeWidth: 4,
                ),
              ),
            // Main SOS button
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emergency,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergency.withOpacity(0.6),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _isSending
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SosOption extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _SosOption({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
