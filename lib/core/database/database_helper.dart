// lib/core/database/database_helper.dart
// ============================================================
// SQLite database helper using sqflite (mobile) / sqflite_common_ffi
// (Windows desktop). Pre-seeds ALL survival content on first launch.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// sqflite is re-exported by sqflite_common_ffi, but we also import
// it directly so that getDatabasesPath() works on Android/iOS
import 'package:sqflite/sqflite.dart' as sqflite_mobile;
import '../models/first_aid_model.dart';

class DatabaseHelper {
  static const String _dbName = 'disaster_survival.db';
  static const int _dbVersion = 1;

  static Database? _database;

  // Singleton accessor
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database factory for current platform
  static Future<Database> _initDatabase() async {
    String dbPath;

    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // ── Desktop: use FFI driver ────────────────────────────
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dbPath = await getDatabasesPath();
    } else if (kIsWeb) {
      // ── Web: not supported, use in-memory ─────────────────
      dbPath = inMemoryDatabasePath;
    } else {
      // ── Mobile (Android / iOS): use native sqflite ────────
      dbPath = await sqflite_mobile.getDatabasesPath();
    }

    final path = kIsWeb ? inMemoryDatabasePath : p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all tables and seed initial data
  static Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedFirstAidCategories(db);
    await _seedFirstAidSteps(db);
    await _seedKitItems(db);
    await _seedSafeZones(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop and recreate on major version bump
    await db.execute('DROP TABLE IF EXISTS first_aid_categories');
    await db.execute('DROP TABLE IF EXISTS first_aid_steps');
    await db.execute('DROP TABLE IF EXISTS kit_items');
    await db.execute('DROP TABLE IF EXISTS safe_zones');
    await _onCreate(db, newVersion);
  }

  // ── Table Definitions ─────────────────────────────────────
  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE first_aid_categories (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        key         TEXT    NOT NULL UNIQUE,
        label       TEXT    NOT NULL,
        emoji       TEXT    NOT NULL,
        color_hex   TEXT    NOT NULL,
        step_count  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE first_aid_steps (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        category_key        TEXT    NOT NULL,
        step_number         INTEGER NOT NULL,
        instruction_text    TEXT    NOT NULL,
        illustration_emoji  TEXT    NOT NULL,
        icon_name           TEXT    NOT NULL,
        FOREIGN KEY (category_key) REFERENCES first_aid_categories(key)
      )
    ''');

    await db.execute('''
      CREATE TABLE kit_items (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        label       TEXT    NOT NULL,
        emoji       TEXT    NOT NULL,
        category    TEXT    NOT NULL,
        is_checked  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE safe_zones (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        latitude    REAL    NOT NULL,
        longitude   REAL    NOT NULL,
        type        TEXT    NOT NULL,
        emoji       TEXT    NOT NULL
      )
    ''');
  }

  // ── Seed: First Aid Categories ────────────────────────────
  static Future<void> _seedFirstAidCategories(Database db) async {
    final categories = [
      {
        'key': 'bleeding',
        'label': 'Bleeding',
        'emoji': '🩸',
        'color_hex': 'FF1744',
        'step_count': 6,
      },
      {
        'key': 'burns',
        'label': 'Burns',
        'emoji': '🔥',
        'color_hex': 'FF6D00',
        'step_count': 5,
      },
      {
        'key': 'choking',
        'label': 'Choking',
        'emoji': '🤚',
        'color_hex': 'D500F9',
        'step_count': 5,
      },
      {
        'key': 'fracture',
        'label': 'Broken Bone',
        'emoji': '🦴',
        'color_hex': '795548',
        'step_count': 5,
      },
      {
        'key': 'cpr',
        'label': 'CPR',
        'emoji': '❤️',
        'color_hex': 'E91E63',
        'step_count': 6,
      },
      {
        'key': 'shock',
        'label': 'Shock',
        'emoji': '⚡',
        'color_hex': 'FFC400',
        'step_count': 5,
      },
    ];

    for (final cat in categories) {
      await db.insert('first_aid_categories', cat);
    }
  }

  // ── Seed: First Aid Steps ─────────────────────────────────
  static Future<void> _seedFirstAidSteps(Database db) async {
    final steps = [
      // ---- BLEEDING ----
      {'category_key': 'bleeding', 'step_number': 1, 'instruction_text': 'STAY CALM\nCall for help', 'illustration_emoji': '🧘', 'icon_name': 'calm'},
      {'category_key': 'bleeding', 'step_number': 2, 'instruction_text': 'PRESS HARD\non the wound', 'illustration_emoji': '🤚', 'icon_name': 'press'},
      {'category_key': 'bleeding', 'step_number': 3, 'instruction_text': 'USE CLEAN\ncloth or bandage', 'illustration_emoji': '🩹', 'icon_name': 'bandage'},
      {'category_key': 'bleeding', 'step_number': 4, 'instruction_text': 'KEEP PRESSING\nDo NOT remove cloth', 'illustration_emoji': '💪', 'icon_name': 'keep_pressing'},
      {'category_key': 'bleeding', 'step_number': 5, 'instruction_text': 'RAISE the wounded\nbody part UP high', 'illustration_emoji': '⬆️', 'icon_name': 'elevate'},
      {'category_key': 'bleeding', 'step_number': 6, 'instruction_text': 'GET HELP NOW\nDo NOT wait', 'illustration_emoji': '🚑', 'icon_name': 'ambulance'},

      // ---- BURNS ----
      {'category_key': 'burns', 'step_number': 1, 'instruction_text': 'MOVE AWAY\nfrom heat source', 'illustration_emoji': '🏃', 'icon_name': 'run'},
      {'category_key': 'burns', 'step_number': 2, 'instruction_text': 'COOL the burn\nwith cold water 20 min', 'illustration_emoji': '💧', 'icon_name': 'water'},
      {'category_key': 'burns', 'step_number': 3, 'instruction_text': 'DO NOT use\nice or butter', 'illustration_emoji': '🚫', 'icon_name': 'no'},
      {'category_key': 'burns', 'step_number': 4, 'instruction_text': 'COVER loosely\nwith clean cloth', 'illustration_emoji': '🩹', 'icon_name': 'cover'},
      {'category_key': 'burns', 'step_number': 5, 'instruction_text': 'GET HELP\nfor large burns', 'illustration_emoji': '🚑', 'icon_name': 'ambulance'},

      // ---- CHOKING ----
      {'category_key': 'choking', 'step_number': 1, 'instruction_text': 'ASK: Are you\nchoking?', 'illustration_emoji': '🤔', 'icon_name': 'question'},
      {'category_key': 'choking', 'step_number': 2, 'instruction_text': 'LEAN them\nFORWARD', 'illustration_emoji': '⬇️', 'icon_name': 'lean'},
      {'category_key': 'choking', 'step_number': 3, 'instruction_text': 'HIT their back\n5 firm blows', 'illustration_emoji': '✋', 'icon_name': 'back_blow'},
      {'category_key': 'choking', 'step_number': 4, 'instruction_text': 'THRUST upward\non belly 5 times', 'illustration_emoji': '👊', 'icon_name': 'abdominal'},
      {'category_key': 'choking', 'step_number': 5, 'instruction_text': 'REPEAT until\nobject is OUT', 'illustration_emoji': '🔄', 'icon_name': 'repeat'},

      // ---- FRACTURE ----
      {'category_key': 'fracture', 'step_number': 1, 'instruction_text': 'DO NOT MOVE\nthe injured part', 'illustration_emoji': '🛑', 'icon_name': 'stop'},
      {'category_key': 'fracture', 'step_number': 2, 'instruction_text': 'SUPPORT the\nlimb gently', 'illustration_emoji': '🤲', 'icon_name': 'support'},
      {'category_key': 'fracture', 'step_number': 3, 'instruction_text': 'APPLY ice pack\n20 minutes', 'illustration_emoji': '🧊', 'icon_name': 'ice'},
      {'category_key': 'fracture', 'step_number': 4, 'instruction_text': 'MAKE a splint\nwith stiff object', 'illustration_emoji': '📏', 'icon_name': 'splint'},
      {'category_key': 'fracture', 'step_number': 5, 'instruction_text': 'GET TO HOSPITAL\nas soon as possible', 'illustration_emoji': '🏥', 'icon_name': 'hospital'},

      // ---- CPR ----
      {'category_key': 'cpr', 'step_number': 1, 'instruction_text': 'CHECK if person\nis breathing', 'illustration_emoji': '👁️', 'icon_name': 'check'},
      {'category_key': 'cpr', 'step_number': 2, 'instruction_text': 'CALL for help\nimmediately', 'illustration_emoji': '📣', 'icon_name': 'shout'},
      {'category_key': 'cpr', 'step_number': 3, 'instruction_text': 'TILT head back\nLIFT chin up', 'illustration_emoji': '⬆️', 'icon_name': 'tilt'},
      {'category_key': 'cpr', 'step_number': 4, 'instruction_text': 'PRESS chest hard\n30 times fast', 'illustration_emoji': '💓', 'icon_name': 'compress'},
      {'category_key': 'cpr', 'step_number': 5, 'instruction_text': 'BLOW 2 breaths\ninto mouth', 'illustration_emoji': '💨', 'icon_name': 'breathe'},
      {'category_key': 'cpr', 'step_number': 6, 'instruction_text': 'REPEAT until\nhelp arrives', 'illustration_emoji': '🔄', 'icon_name': 'repeat'},

      // ---- SHOCK ----
      {'category_key': 'shock', 'step_number': 1, 'instruction_text': 'LAY person\nFLAT down', 'illustration_emoji': '🛏️', 'icon_name': 'lay'},
      {'category_key': 'shock', 'step_number': 2, 'instruction_text': 'RAISE legs\n30cm high', 'illustration_emoji': '⬆️', 'icon_name': 'elevate'},
      {'category_key': 'shock', 'step_number': 3, 'instruction_text': 'KEEP WARM\ncover with blanket', 'illustration_emoji': '🛡️', 'icon_name': 'warm'},
      {'category_key': 'shock', 'step_number': 4, 'instruction_text': 'DO NOT give\nfood or water', 'illustration_emoji': '🚫', 'icon_name': 'no_food'},
      {'category_key': 'shock', 'step_number': 5, 'instruction_text': 'GET HELP\nurgently', 'illustration_emoji': '🚑', 'icon_name': 'ambulance'},
    ];

    for (final step in steps) {
      await db.insert('first_aid_steps', step);
    }
  }

  // ── Seed: Kit Items ───────────────────────────────────────
  static Future<void> _seedKitItems(Database db) async {
    final items = [
      // Water
      {'label': 'Water Bottles', 'emoji': '💧', 'category': 'water', 'is_checked': 0},
      {'label': 'Water Filter', 'emoji': '🔵', 'category': 'water', 'is_checked': 0},
      {'label': 'Water Tablets', 'emoji': '💊', 'category': 'water', 'is_checked': 0},

      // Food
      {'label': 'Canned Food', 'emoji': '🥫', 'category': 'food', 'is_checked': 0},
      {'label': 'Energy Bars', 'emoji': '🍫', 'category': 'food', 'is_checked': 0},
      {'label': 'Dried Fruits', 'emoji': '🍇', 'category': 'food', 'is_checked': 0},

      // Medical
      {'label': 'Bandages', 'emoji': '🩹', 'category': 'medical', 'is_checked': 0},
      {'label': 'Antiseptic', 'emoji': '🧴', 'category': 'medical', 'is_checked': 0},
      {'label': 'Pain Killers', 'emoji': '💊', 'category': 'medical', 'is_checked': 0},
      {'label': 'Gloves', 'emoji': '🧤', 'category': 'medical', 'is_checked': 0},
      {'label': 'Thermometer', 'emoji': '🌡️', 'category': 'medical', 'is_checked': 0},

      // Tools
      {'label': 'Flashlight', 'emoji': '🔦', 'category': 'tools', 'is_checked': 0},
      {'label': 'Batteries', 'emoji': '🔋', 'category': 'tools', 'is_checked': 0},
      {'label': 'Multi-Tool', 'emoji': '🔧', 'category': 'tools', 'is_checked': 0},
      {'label': 'Whistle', 'emoji': '📯', 'category': 'tools', 'is_checked': 0},
      {'label': 'Rope', 'emoji': '🪢', 'category': 'tools', 'is_checked': 0},
      {'label': 'Lighter / Matches', 'emoji': '🔥', 'category': 'tools', 'is_checked': 0},
      {'label': 'Knife', 'emoji': '🔪', 'category': 'tools', 'is_checked': 0},

      // Shelter
      {'label': 'Emergency Blanket', 'emoji': '🛡️', 'category': 'shelter', 'is_checked': 0},
      {'label': 'Tent / Tarp', 'emoji': '⛺', 'category': 'shelter', 'is_checked': 0},
      {'label': 'Rain Poncho', 'emoji': '🧥', 'category': 'shelter', 'is_checked': 0},
      {'label': 'Warm Clothes', 'emoji': '👕', 'category': 'shelter', 'is_checked': 0},
      {'label': 'Sleeping Bag', 'emoji': '🛏️', 'category': 'shelter', 'is_checked': 0},

      // Documents & Comms
      {'label': 'ID Documents', 'emoji': '🪪', 'category': 'docs', 'is_checked': 0},
      {'label': 'Cash / Money', 'emoji': '💵', 'category': 'docs', 'is_checked': 0},
      {'label': 'Phone Charger', 'emoji': '🔌', 'category': 'docs', 'is_checked': 0},
      {'label': 'Power Bank', 'emoji': '🔋', 'category': 'docs', 'is_checked': 0},
      {'label': 'Emergency Numbers', 'emoji': '📋', 'category': 'docs', 'is_checked': 0},
    ];

    for (final item in items) {
      await db.insert('kit_items', item);
    }
  }

  // ── Seed: Safe Zones ──────────────────────────────────────
  // NOTE: These are sample safe zone coordinates. In production,
  // replace with real local safe zone GPS coordinates.
  static Future<void> _seedSafeZones(Database db) async {
    final zones = [
      {'name': 'City Emergency Shelter', 'latitude': 28.6139, 'longitude': 77.2090, 'type': 'shelter', 'emoji': '🏠'},
      {'name': 'Red Cross Hospital', 'latitude': 28.6180, 'longitude': 77.2150, 'type': 'hospital', 'emoji': '🏥'},
      {'name': 'Water Distribution Point', 'latitude': 28.6100, 'longitude': 77.2050, 'type': 'water', 'emoji': '💧'},
      {'name': 'Stadium Evacuation Zone', 'latitude': 28.6200, 'longitude': 77.2120, 'type': 'evacuation', 'emoji': '🏟️'},
      {'name': 'School Safety Zone', 'latitude': 28.6050, 'longitude': 77.2030, 'type': 'shelter', 'emoji': '🏫'},
    ];

    for (final zone in zones) {
      await db.insert('safe_zones', zone);
    }
  }

  // ── CRUD Operations ───────────────────────────────────────

  /// Fetch all first aid categories
  static Future<List<FirstAidCategory>> getFirstAidCategories() async {
    final db = await database;
    final maps = await db.query('first_aid_categories');
    return maps.map((m) => FirstAidCategory.fromMap(m)).toList();
  }

  /// Fetch steps for a given category
  static Future<List<FirstAidStep>> getFirstAidSteps(String categoryKey) async {
    final db = await database;
    final maps = await db.query(
      'first_aid_steps',
      where: 'category_key = ?',
      whereArgs: [categoryKey],
      orderBy: 'step_number ASC',
    );
    return maps.map((m) => FirstAidStep.fromMap(m)).toList();
  }

  /// Fetch all kit items
  static Future<List<KitItem>> getKitItems() async {
    final db = await database;
    final maps = await db.query('kit_items', orderBy: 'category ASC');
    return maps.map((m) => KitItem.fromMap(m)).toList();
  }

  /// Update a kit item's checked state
  static Future<void> updateKitItem(KitItem item) async {
    final db = await database;
    await db.update(
      'kit_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Reset all kit items to unchecked
  static Future<void> resetKitItems() async {
    final db = await database;
    await db.update('kit_items', {'is_checked': 0});
  }

  /// Fetch all safe zones
  static Future<List<SafeZone>> getSafeZones() async {
    final db = await database;
    final maps = await db.query('safe_zones');
    return maps.map((m) => SafeZone.fromMap(m)).toList();
  }
}
