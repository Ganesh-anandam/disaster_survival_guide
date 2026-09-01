// lib/features/home/home_screen.dart
// ============================================================
// Main Home Screen: Color-coded triage grid with 4 main features.
// Visual-first design with massive icons, minimal text.
// Persistent SOS button at bottom.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/sos_fab.dart';
import '../first_aid/first_aid_screen.dart';
import '../kit_builder/kit_builder_screen.dart';
import '../compass/compass_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Force landscape / portrait support
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            _buildHeader(context),

            // ── Alert Banner ────────────────────────────────
            _buildAlertBanner(),

            // ── Main Triage Grid ────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _buildTriageGrid(context),
              ),
            ),

            // ── Bottom Info Bar ─────────────────────────────
            _buildBottomBar(),

            // ── SOS Section ─────────────────────────────────
            _buildSosSection(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          // App title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚡ SURVIVAL',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.emergency,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'GUIDE',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 5,
                  height: 0.8,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Battery saver indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.safe.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.safe.withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔋', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text(
                  'OFFLINE',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.safe,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  // ── Alert Banner ──────────────────────────────────────────
  Widget _buildAlertBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.emergency.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emergency.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Text('🚨', style: TextStyle(fontSize: 20)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'TAP a section below. HOLD SOS to send emergency message.',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }

  // ── Main Triage Grid ──────────────────────────────────────
  Widget _buildTriageGrid(BuildContext context) {
    final cards = [
      _TriageCard(
        emoji: '🩺',
        title: 'FIRST AID',
        subtitle: 'Emergency help',
        color: AppColors.emergency,
        glowColor: AppColors.emergencyGlow,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FirstAidScreen()),
        ),
        delay: 0,
      ),
      _TriageCard(
        emoji: '🎒',
        title: 'SURVIVAL KIT',
        subtitle: 'Pack checklist',
        color: AppColors.alert,
        glowColor: AppColors.alertGlow,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KitBuilderScreen()),
        ),
        delay: 100,
      ),
      _TriageCard(
        emoji: '🧭',
        title: 'SAFE ROUTE',
        subtitle: 'Find safe zone',
        color: AppColors.resource,
        glowColor: AppColors.resourceGlow,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CompassScreen()),
        ),
        delay: 200,
      ),
      _TriageCard(
        emoji: '💧',
        title: 'SURVIVAL TIPS',
        subtitle: 'Water & shelter',
        color: AppColors.safe,
        glowColor: AppColors.safeGlow,
        onTap: () => _showSurvivalTips(context),
        delay: 300,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = constraints.maxWidth > 500;
        return GridView.count(
          crossAxisCount: isLarge ? 4 : 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,
          physics: const NeverScrollableScrollPhysics(),
          children: cards,
        );
      },
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatusChip(emoji: '📡', label: 'GPS ON', color: AppColors.safe),
          _StatusChip(emoji: '💾', label: 'DATA LOCAL', color: AppColors.resource),
          _StatusChip(emoji: '🔕', label: 'NO INTERNET', color: AppColors.alert),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms);
  }

  // ── SOS Section ───────────────────────────────────────────
  Widget _buildSosSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  'HOLD for 1.5s to SEND SOS',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sends GPS location via SMS',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          const SosFab(),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }

  // ── Survival Tips Sheet ───────────────────────────────────
  void _showSurvivalTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => _SurvivalTipsSheet(controller: controller),
      ),
    );
  }
}

// ── Triage Card Widget ─────────────────────────────────────
class _TriageCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Color glowColor;
  final VoidCallback onTap;
  final int delay;

  const _TriageCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.glowColor,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_TriageCard> createState() => _TriageCardState();
}

class _TriageCardState extends State<_TriageCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.93 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.color.withOpacity(0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.glowColor,
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large emoji icon
            Text(
              widget.emoji,
              style: const TextStyle(fontSize: 52),
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              widget.title,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: widget.color,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Subtitle
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Arrow indicator
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: widget.color,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay + 400))
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }
}

// ── Status Chip ───────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _StatusChip({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Survival Tips Sheet ───────────────────────────────────
class _SurvivalTipsSheet extends StatelessWidget {
  final ScrollController controller;

  const _SurvivalTipsSheet({required this.controller});

  static const _tips = [
    ('💧', 'Water', 'Drink at least 2L per day. Boil or purify any collected water. Look for moving water sources.'),
    ('🔥', 'Fire', 'Fire = warmth, safety, signal. Use dry materials. Strike flint in sheltered spot.'),
    ('⛺', 'Shelter', 'Stay DRY and WARM above all else. Insulate from ground. Face away from wind.'),
    ('🍃', 'Food', 'Humans survive 3 weeks without food. Prioritize water first. Avoid unknown plants.'),
    ('📡', 'Signal', 'Mirror reflects sun 16km. Whistle carries farther than voice. SOS in open clearings.'),
    ('🧠', 'Psychology', 'STOP: Stop, Think, Observe, Plan. Panic kills. Breathe slowly. One step at a time.'),
    ('🧭', 'Navigation', 'Sun rises EAST, sets WEST. Moss grows on north side. Stars point North.'),
    ('🤝', 'Groups', 'Stay together. Share resources. Assign roles. Keep moving every 4 hours max.'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '💡 SURVIVAL TIPS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.safe,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        ..._tips.map((tip) => _TipCard(
          emoji: tip.$1,
          title: tip.$2,
          body: tip.$3,
        )),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;

  const _TipCard({required this.emoji, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.safe,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
