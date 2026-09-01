// lib/widgets/common/pulse_button.dart
// ============================================================
// Reusable pulsing animated button widget for emergency actions.
// Creates a glowing, beating visual effect to draw attention.
// ============================================================

import 'package:flutter/material.dart';

class PulseButton extends StatefulWidget {
  final String emoji;
  final String label;
  final Color color;
  final Color glowColor;
  final VoidCallback onTap;
  final double size;
  final bool isPulsing;

  const PulseButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.color,
    required this.glowColor,
    required this.onTap,
    this.size = 100,
    this.isPulsing = false,
  });

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.animateTo(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressed ? 0.94 : (widget.isPulsing ? _scaleAnimation.value : 1.0),
            child: child,
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: widget.color, width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor,
                blurRadius: 20,
                spreadRadius: widget.isPulsing ? 4 : 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.emoji,
                style: TextStyle(fontSize: widget.size * 0.38),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                  letterSpacing: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
