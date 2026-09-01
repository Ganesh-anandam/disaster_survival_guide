// lib/features/compass/compass_screen.dart
// ============================================================
// Offline Compass Navigation - Blue Section
// Shows a massive directional arrow pointing to selected safe zone.
// Distance updates in real-time from GPS.
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/providers/compass_provider.dart';
import '../../core/models/first_aid_model.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/sos_fab.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CompassProvider>();
      await provider.loadSafeZones();
      await provider.startTracking();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () {
            context.read<CompassProvider>().stopTracking();
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧭', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              'SAFE ROUTE',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.resource,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: const SosFab(),
          ),
        ],
      ),
      body: Consumer<CompassProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // ── Zone Selector ──────────────────────────────
              _buildZoneSelector(context, provider),

              // ── Main Compass Display ───────────────────────
              Expanded(
                child: _buildCompassDisplay(provider),
              ),

              // ── Safe Zone List ─────────────────────────────
              _buildZoneList(context, provider),
            ],
          );
        },
      ),
    );
  }

  // ── Zone Selector Pills ───────────────────────────────────
  Widget _buildZoneSelector(BuildContext context, CompassProvider provider) {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.safeZones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final zone = provider.safeZones[index];
          final isSelected = provider.selectedZone?.id == zone.id;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              provider.selectZone(zone);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.resource.withOpacity(0.2)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? AppColors.resource : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(zone.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    zone.name.split(' ').take(2).join(' ').toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.resource : AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Main Compass Display ──────────────────────────────────
  Widget _buildCompassDisplay(CompassProvider provider) {
    if (provider.errorMessage.isNotEmpty) {
      return _buildErrorState(provider.errorMessage);
    }

    if (!provider.hasLocation) {
      return _buildWaitingState();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Distance indicator
        _buildDistanceIndicator(provider),

        const SizedBox(height: 32),

        // Animated compass arrow
        _buildCompassArrow(provider),

        const SizedBox(height: 32),

        // Selected zone info
        if (provider.selectedZone != null)
          _buildZoneInfo(provider.selectedZone!),
      ],
    );
  }

  Widget _buildDistanceIndicator(CompassProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.resource.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.resource.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            provider.distanceLabel,
            style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 52,
              fontWeight: FontWeight.w700,
              color: AppColors.resource,
              letterSpacing: 2,
            ),
          ),
          const Text(
            'DISTANCE TO SAFE ZONE',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildCompassArrow(CompassProvider provider) {
    final bearing = provider.bearing ?? 0;
    // Convert bearing (0=North) to radians for Transform.rotate
    final radians = bearing * math.pi / 180;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.resource.withOpacity(0.05),
              border: Border.all(
                color: AppColors.resource.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          // Cardinal points
          ..._buildCardinalPoints(),
          // Rotating arrow
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: radians, end: radians),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value,
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // North arrow (red tip)
                Container(
                  width: 16,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.resource,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.resource.withOpacity(0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Arrow triangle head
                CustomPaint(
                  size: const Size(30, 24),
                  painter: _ArrowHeadPainter(color: AppColors.resource),
                ),
                // South arrow (muted)
                Container(
                  width: 10,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Center dot
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }


  List<Widget> _buildCardinalPoints() {
    // (label, topOffset from center, leftOffset from center)
    final points = [
      ('N', 100.0 - 80.0 - 10, 100.0 - 10),
      ('S', 100.0 + 80.0 - 10, 100.0 - 10),
      ('W', 100.0 - 10,        100.0 - 80.0 - 10),
      ('E', 100.0 - 10,        100.0 + 80.0 - 10),
    ];

    return points.map((p) {
      return Positioned(
        top: p.$2,
        left: p.$3,
        child: Text(
          p.$1,
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: p.$1 == 'N' ? AppColors.emergency : AppColors.textMuted,
          ),
        ),
      );
    }).toList();
  }


  Widget _buildZoneInfo(SafeZone zone) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(zone.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  zone.type.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 13,
                    color: AppColors.resource,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.navigation_rounded, color: AppColors.resource, size: 28),
        ],
      ),
    );
  }

  Widget _buildWaitingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📡', style: TextStyle(fontSize: 80))
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 600.ms)
              .fadeOut(delay: 600.ms, duration: 400.ms),
          const SizedBox(height: 24),
          const Text(
            'FINDING YOUR LOCATION...',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.resource,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Make sure GPS is turned ON',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(color: AppColors.resource),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.alert,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.resource,
                minimumSize: const Size(200, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => context.read<CompassProvider>().startTracking(),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'RETRY GPS',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Safe Zone List ────────────────────────────────────────
  Widget _buildZoneList(BuildContext context, CompassProvider provider) {
    return Container(
      height: 100,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📍 NEARBY SAFE ZONES',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.safeZones.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, index) {
                final zone = provider.safeZones[index];
                final isSelected = provider.selectedZone?.id == zone.id;
                return GestureDetector(
                  onTap: () => provider.selectZone(zone),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 90,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.resource.withOpacity(0.15)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.resource : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(zone.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          zone.name.split(' ').first.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.resource
                                : AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Arrow Head Painter ─────────────────────────────────────
class _ArrowHeadPainter extends CustomPainter {
  final Color color;
  _ArrowHeadPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowHeadPainter old) => old.color != color;
}
