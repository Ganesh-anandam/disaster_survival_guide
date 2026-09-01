// lib/features/first_aid/first_aid_screen.dart
// ============================================================
// Visual First Aid Menu - Red Section
// Grid of first aid categories (Bleeding, Burns, Choking, etc.)
// Each category shows a step-by-step visual slider.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/providers/first_aid_provider.dart';
import '../../core/models/first_aid_model.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/sos_fab.dart';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen> {
  @override
  void initState() {
    super.initState();
    // Load categories from SQLite on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FirstAidProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🩺', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              'FIRST AID',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.emergency,
                letterSpacing: 3,
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
      body: Consumer<FirstAidProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.emergency),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Instruction Banner ─────────────────────────
              _buildInstructionBanner(),

              // ── Category Grid ──────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final cat = provider.categories[index];
                      return _CategoryCard(
                        category: cat,
                        delay: index * 80,
                        onTap: () => _openSteps(context, cat, provider),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInstructionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.emergency.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emergency.withOpacity(0.25)),
      ),
      child: const Row(
        children: [
          Text('👆', style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'TAP any emergency below for step-by-step visual guide',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSteps(
    BuildContext context,
    FirstAidCategory category,
    FirstAidProvider provider,
  ) {
    HapticFeedback.lightImpact();
    provider.selectCategory(category).then((_) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: provider,
              child: FirstAidStepsScreen(category: category),
            ),
          ),
        );
      }
    });
  }
}

// ── Category Card ─────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final FirstAidCategory category;
  final VoidCallback onTap;
  final int delay;

  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _color {
    final hex = widget.category.colorHex;
    return Color(int.parse('FF$hex', radix: 16));
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
          color: _color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _color.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _color.withOpacity(0.15),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji illustration
            Text(
              widget.category.emoji,
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 12),
            // Category name
            Text(
              widget.category.label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _color,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            // Step count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.category.stepCount} STEPS',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _color,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay + 200))
        .fadeIn(duration: 350.ms)
        .scale(begin: const Offset(0.85, 0.85));
  }
}

// ════════════════════════════════════════════════════════════
// First Aid Steps Screen - Visual Step-by-Step Slider
// ════════════════════════════════════════════════════════════
class FirstAidStepsScreen extends StatelessWidget {
  final FirstAidCategory category;

  const FirstAidStepsScreen({super.key, required this.category});

  Color get _color {
    final hex = category.colorHex;
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${category.emoji} ${category.label.toUpperCase()}',
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _color,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Consumer<FirstAidProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading || provider.currentSteps.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.emergency),
            );
          }

          final step = provider.currentStep!;
          final totalSteps = provider.currentSteps.length;
          final currentIndex = provider.currentStepIndex;

          return Column(
            children: [
              // ── Progress Indicator ───────────────────────
              _buildProgressBar(context, provider),

              // ── Step Display ─────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.3, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _StepDisplay(
                    key: ValueKey(currentIndex),
                    step: step,
                    stepNumber: currentIndex + 1,
                    totalSteps: totalSteps,
                    color: _color,
                  ),
                ),
              ),

              // ── Navigation Buttons ───────────────────────
              _buildNavButtons(context, provider, currentIndex, totalSteps),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, FirstAidProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP ${provider.currentStepIndex + 1}',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _color,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'OF ${provider.currentSteps.length}',
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: provider.stepProgress,
              backgroundColor: _color.withOpacity(0.15),
              color: _color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons(
    BuildContext context,
    FirstAidProvider provider,
    int currentIndex,
    int totalSteps,
  ) {
    final isLast = currentIndex == totalSteps - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Row(
        children: [
          // BACK button
          if (provider.hasPrevStep) ...[
            Expanded(
              flex: 1,
              child: _NavButton(
                label: '◀ BACK',
                color: AppColors.textSecondary,
                backgroundColor: AppColors.surfaceVariant,
                onTap: () {
                  HapticFeedback.selectionClick();
                  provider.prevStep();
                },
              ),
            ),
            const SizedBox(width: 12),
          ],

          // NEXT / DONE button
          Expanded(
            flex: 2,
            child: _NavButton(
              label: isLast ? '✅ DONE' : 'NEXT ▶',
              color: Colors.white,
              backgroundColor: isLast ? AppColors.safe : _color,
              onTap: () {
                HapticFeedback.lightImpact();
                if (isLast) {
                  provider.resetSteps();
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  provider.nextStep();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Display Widget ───────────────────────────────────
class _StepDisplay extends StatelessWidget {
  final FirstAidStep step;
  final int stepNumber;
  final int totalSteps;
  final Color color;

  const _StepDisplay({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step number badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Giant illustration emoji
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.25), width: 2),
            ),
            child: Center(
              child: Text(
                step.illustrationEmoji,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: 32),

          // Instruction text - large, clear
          Text(
            step.instructionText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
              height: 1.3,
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          // Swipe hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe_right_rounded, color: color.withOpacity(0.4), size: 18),
              const SizedBox(width: 6),
              Text(
                'TAP NEXT to continue',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 12,
                  color: color.withOpacity(0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Navigation Button ─────────────────────────────────────
class _NavButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: widget.color,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
