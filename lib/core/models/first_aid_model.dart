// lib/core/models/first_aid_model.dart
// ============================================================
// Data models for First Aid steps, categories, Kit items, and
// Safe Zone compass targets. All data is pre-seeded in SQLite.
// ============================================================

class FirstAidCategory {
  final int? id;
  final String key;          // e.g., "bleeding"
  final String label;        // e.g., "Bleeding"
  final String emoji;        // Unicode fallback emoji
  final String colorHex;     // Hex color for the card
  final int stepCount;

  const FirstAidCategory({
    this.id,
    required this.key,
    required this.label,
    required this.emoji,
    required this.colorHex,
    required this.stepCount,
  });

  factory FirstAidCategory.fromMap(Map<String, dynamic> map) {
    return FirstAidCategory(
      id: map['id'] as int?,
      key: map['key'] as String,
      label: map['label'] as String,
      emoji: map['emoji'] as String,
      colorHex: map['color_hex'] as String,
      stepCount: map['step_count'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
    'key': key,
    'label': label,
    'emoji': emoji,
    'color_hex': colorHex,
    'step_count': stepCount,
  };
}

class FirstAidStep {
  final int? id;
  final String categoryKey;
  final int stepNumber;
  final String instructionText;   // Short, simple text
  final String illustrationEmoji; // Large emoji illustration fallback
  final String iconName;          // Icon identifier

  const FirstAidStep({
    this.id,
    required this.categoryKey,
    required this.stepNumber,
    required this.instructionText,
    required this.illustrationEmoji,
    required this.iconName,
  });

  factory FirstAidStep.fromMap(Map<String, dynamic> map) {
    return FirstAidStep(
      id: map['id'] as int?,
      categoryKey: map['category_key'] as String,
      stepNumber: map['step_number'] as int,
      instructionText: map['instruction_text'] as String,
      illustrationEmoji: map['illustration_emoji'] as String,
      iconName: map['icon_name'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'category_key': categoryKey,
    'step_number': stepNumber,
    'instruction_text': instructionText,
    'illustration_emoji': illustrationEmoji,
    'icon_name': iconName,
  };
}

// ---- Kit Item Model ----
class KitItem {
  final int? id;
  final String label;
  final String emoji;
  final String category;  // "water", "shelter", "medical", "tools", "food"
  bool isChecked;

  KitItem({
    this.id,
    required this.label,
    required this.emoji,
    required this.category,
    this.isChecked = false,
  });

  factory KitItem.fromMap(Map<String, dynamic> map) {
    return KitItem(
      id: map['id'] as int?,
      label: map['label'] as String,
      emoji: map['emoji'] as String,
      category: map['category'] as String,
      isChecked: (map['is_checked'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'label': label,
    'emoji': emoji,
    'category': category,
    'is_checked': isChecked ? 1 : 0,
  };

  KitItem copyWith({bool? isChecked}) {
    return KitItem(
      id: id,
      label: label,
      emoji: emoji,
      category: category,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

// ---- Safe Zone Model ----
class SafeZone {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String type;     // "shelter", "water", "hospital", "evacuation"
  final String emoji;

  const SafeZone({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.emoji,
  });

  factory SafeZone.fromMap(Map<String, dynamic> map) {
    return SafeZone(
      id: map['id'] as int?,
      name: map['name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      type: map['type'] as String,
      emoji: map['emoji'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'type': type,
    'emoji': emoji,
  };
}

// ---- SOS Contact Model ----
class SosContact {
  final String name;
  final String phoneNumber;

  const SosContact({required this.name, required this.phoneNumber});
}
