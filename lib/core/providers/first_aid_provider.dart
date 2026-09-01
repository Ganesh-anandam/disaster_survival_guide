// lib/core/providers/first_aid_provider.dart
// ============================================================
// Provider managing all First Aid state. Loads from SQLite.
// ============================================================

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/first_aid_model.dart';

class FirstAidProvider extends ChangeNotifier {
  List<FirstAidCategory> _categories = [];
  List<FirstAidStep> _currentSteps = [];
  FirstAidCategory? _selectedCategory;
  int _currentStepIndex = 0;
  bool _isLoading = false;

  // ── Getters ────────────────────────────────────────────────
  List<FirstAidCategory> get categories => _categories;
  List<FirstAidStep> get currentSteps => _currentSteps;
  FirstAidCategory? get selectedCategory => _selectedCategory;
  int get currentStepIndex => _currentStepIndex;
  bool get isLoading => _isLoading;

  FirstAidStep? get currentStep =>
      _currentSteps.isNotEmpty && _currentStepIndex < _currentSteps.length
          ? _currentSteps[_currentStepIndex]
          : null;

  bool get hasNextStep => _currentStepIndex < _currentSteps.length - 1;
  bool get hasPrevStep => _currentStepIndex > 0;
  double get stepProgress =>
      _currentSteps.isEmpty ? 0 : (_currentStepIndex + 1) / _currentSteps.length;

  // ── Load categories from DB ────────────────────────────────
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await DatabaseHelper.getFirstAidCategories();
    } catch (e) {
      debugPrint('Error loading first aid categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Select a category and load its steps ───────────────────
  Future<void> selectCategory(FirstAidCategory category) async {
    _selectedCategory = category;
    _currentStepIndex = 0;
    _isLoading = true;
    notifyListeners();
    try {
      _currentSteps = await DatabaseHelper.getFirstAidSteps(category.key);
    } catch (e) {
      debugPrint('Error loading steps for ${category.key}: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Step navigation ────────────────────────────────────────
  void nextStep() {
    if (hasNextStep) {
      _currentStepIndex++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (hasPrevStep) {
      _currentStepIndex--;
      notifyListeners();
    }
  }

  void resetSteps() {
    _currentStepIndex = 0;
    _selectedCategory = null;
    _currentSteps = [];
    notifyListeners();
  }
}
