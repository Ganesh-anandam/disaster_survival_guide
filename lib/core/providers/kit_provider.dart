// lib/core/providers/kit_provider.dart
// ============================================================
// Provider managing Emergency Kit Builder state.
// Persists checked state to SQLite.
// ============================================================

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/first_aid_model.dart';

class KitProvider extends ChangeNotifier {
  List<KitItem> _items = [];
  bool _isLoading = false;

  List<KitItem> get items => _items;
  bool get isLoading => _isLoading;

  int get checkedCount => _items.where((i) => i.isChecked).length;
  int get totalCount => _items.length;
  double get progress => totalCount == 0 ? 0 : checkedCount / totalCount;

  // Group items by category for display
  Map<String, List<KitItem>> get itemsByCategory {
    final Map<String, List<KitItem>> grouped = {};
    for (final item in _items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  /// Category display names and icons
  static const Map<String, Map<String, String>> categoryMeta = {
    'water':   {'label': 'Water', 'emoji': '💧'},
    'food':    {'label': 'Food', 'emoji': '🥫'},
    'medical': {'label': 'Medical', 'emoji': '🏥'},
    'tools':   {'label': 'Tools', 'emoji': '🔧'},
    'shelter': {'label': 'Shelter', 'emoji': '⛺'},
    'docs':    {'label': 'Documents', 'emoji': '📋'},
  };

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await DatabaseHelper.getKitItems();
    } catch (e) {
      debugPrint('Error loading kit items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleItem(KitItem item) async {
    final updated = item.copyWith(isChecked: !item.isChecked);
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = updated;
      notifyListeners();
      // Persist to SQLite
      await DatabaseHelper.updateKitItem(updated);
    }
  }

  Future<void> resetAll() async {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isChecked: false);
    }
    notifyListeners();
    await DatabaseHelper.resetKitItems();
  }
}
