// lib/features/kit_builder/kit_builder_screen.dart
// ============================================================
// Emergency Kit Builder - Yellow Section
// Icon-based checklist with categories.
// Visual progress bar, SQLite-persisted check states.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/providers/kit_provider.dart';
import '../../core/models/first_aid_model.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/sos_fab.dart';

class KitBuilderScreen extends StatefulWidget {
  const KitBuilderScreen({super.key});

  @override
  State<KitBuilderScreen> createState() => _KitBuilderScreenState();
}

class _KitBuilderScreenState extends State<KitBuilderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KitProvider>().loadItems();
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
            const Text('🎒', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              'SURVIVAL KIT',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.alert,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          // Reset button
          Consumer<KitProvider>(
            builder: (_, prov, __) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
              tooltip: 'Reset all',
              onPressed: () => _showResetDialog(context, prov),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: const SosFab(),
          ),
        ],
      ),
      body: Consumer<KitProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.alert),
            );
          }

          return CustomScrollView(
            slivers: [
              // ── Progress Header ──────────────────────────
              SliverToBoxAdapter(
                child: _buildProgressHeader(provider),
              ),

              // ── Category Sections ────────────────────────
              ...KitProvider.categoryMeta.entries.map((entry) {
                final catKey = entry.key;
                final catMeta = entry.value;
                final catItems = provider.itemsByCategory[catKey] ?? [];
                if (catItems.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                return SliverToBoxAdapter(
                  child: _CategorySection(
                    categoryKey: catKey,
                    emoji: catMeta['emoji']!,
                    label: catMeta['label']!,
                    items: catItems,
                    onToggle: provider.toggleItem,
                  ),
                );
              }),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: _KitFab(),
    );
  }

  Widget _buildProgressHeader(KitProvider provider) {
    final percentage = (provider.progress * 100).toInt();
    final isComplete = provider.checkedCount == provider.totalCount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isComplete ? AppColors.safe : AppColors.alert.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isComplete ? AppColors.safe : AppColors.alert).withOpacity(0.1),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          // Percentage + label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isComplete ? '✅ KIT READY!' : '🎒 PACKING...',
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isComplete ? AppColors.safe : AppColors.alert,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '${provider.checkedCount} of ${provider.totalCount} items packed',
                    style: const TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Big percentage circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isComplete ? AppColors.safe : AppColors.alert).withOpacity(0.15),
                  border: Border.all(
                    color: isComplete ? AppColors.safe : AppColors.alert,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isComplete ? AppColors.safe : AppColors.alert,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: provider.progress,
              backgroundColor: AppColors.border,
              color: isComplete ? AppColors.safe : AppColors.alert,
              minHeight: 10,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  void _showResetDialog(BuildContext context, KitProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '🔄 Reset Kit?',
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This will uncheck all items. Continue?',
          style: TextStyle(fontFamily: 'NotoSans', color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert),
            onPressed: () {
              provider.resetAll();
              Navigator.pop(ctx);
            },
            child: const Text(
              'RESET',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Section ──────────────────────────────────────
class _CategorySection extends StatelessWidget {
  final String categoryKey;
  final String emoji;
  final String label;
  final List<KitItem> items;
  final Future<void> Function(KitItem) onToggle;

  const _CategorySection({
    required this.categoryKey,
    required this.emoji,
    required this.label,
    required this.items,
    required this.onToggle,
  });

  int get _checkedCount => items.where((i) => i.isChecked).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Category header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '$_checkedCount/${items.length}',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _checkedCount == items.length
                        ? AppColors.safe
                        : AppColors.alert,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          // Items grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _KitItemTile(
                  item: items[index],
                  onTap: () => onToggle(items[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Kit Item Tile ─────────────────────────────────────────
class _KitItemTile extends StatefulWidget {
  final KitItem item;
  final VoidCallback onTap;

  const _KitItemTile({required this.item, required this.onTap});

  @override
  State<_KitItemTile> createState() => _KitItemTileState();
}

class _KitItemTileState extends State<_KitItemTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isChecked = widget.item.isChecked;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: isChecked ? _scaleAnim.value : 1.0,
        child: child,
      ),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isChecked
                ? AppColors.safe.withOpacity(0.15)
                : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isChecked ? AppColors.safe : AppColors.border,
              width: isChecked ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Text(
                    widget.item.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  if (isChecked)
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.safe,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.black,
                        size: 12,
                      ),
                    ).animate().scale(duration: 200.ms, curve: Curves.elasticOut),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isChecked ? AppColors.safe : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Kit FAB ───────────────────────────────────────────────
class _KitFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<KitProvider>(
      builder: (_, provider, __) {
        final missing = provider.totalCount - provider.checkedCount;
        if (missing == 0) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: FloatingActionButton.extended(
            backgroundColor: AppColors.alert,
            foregroundColor: Colors.black,
            onPressed: () {},
            icon: const Text('📋', style: TextStyle(fontSize: 20)),
            label: Text(
              '$missing ITEMS LEFT',
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}
