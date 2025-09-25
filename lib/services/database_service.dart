import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'food_passport.db');
    return await openDatabase(
      path,
      version: 2, // ✅ Increased version number for schema update
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Food entries table - matches your current food recognition structure
    await db.execute('''
      CREATE TABLE food_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_name TEXT NOT NULL,
        calories REAL,
        protein REAL,
        carbs REAL,
        fat REAL,
        image_path TEXT,
        latitude REAL,
        longitude REAL,
        address TEXT,
        timestamp INTEGER NOT NULL,
        confidence_score REAL,
        source TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Passport stamps table for gamification
    await db.execute('''
      CREATE TABLE passport_stamps(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stamp_type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        icon_name TEXT,
        earned_date INTEGER NOT NULL,
        category TEXT
      )
    ''');

    // User statistics table
    await db.execute('''
      CREATE TABLE user_stats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_foods_tried INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        best_streak INTEGER DEFAULT 0,
        total_calories REAL DEFAULT 0,
        last_entry_date INTEGER
      )
    ''');
    
    // ✅ NEW: User profile table
    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        allergies TEXT, -- Will store JSON array of allergies
        dietary_preference TEXT,
        country TEXT,
        language TEXT,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // Initialize user stats with default values
    await db.insert('user_stats', {
      'total_foods_tried': 0,
      'current_streak': 0,
      'best_streak': 0,
      'total_calories': 0.0,
      'last_entry_date': null,
    });
    
    // ✅ Initialize user profile with default values
    await db.insert('user_profile', {
      'name': null,
      'age': null,
      'allergies': '[]', // Empty JSON array
      'dietary_preference': null,
      'country': null,
      'language': null,
    });
  }

  // Food entries methods
  Future<int> insertFoodEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert('food_entries', entry);
  }

  Future<List<Map<String, dynamic>>> getFoodEntries() async {
    final db = await database;
    return await db.query('food_entries', orderBy: 'timestamp DESC');
  }

  Future<int> deleteFoodEntry(int id) async {
    final db = await database;
    return await db.delete('food_entries', where: 'id = ?', whereArgs: [id]);
  }

  // Passport stamps methods
  Future<int> addPassportStamp(Map<String, dynamic> stamp) async {
    final db = await database;
    return await db.insert('passport_stamps', stamp);
  }

  Future<List<Map<String, dynamic>>> getPassportStamps() async {
    final db = await database;
    return await db.query('passport_stamps', orderBy: 'earned_date DESC');
  }

  // User stats methods
  Future<void> updateUserStats(Map<String, dynamic> stats) async {
    final db = await database;
    final existing = await getUserStats();
    if (existing == null) {
      await db.insert('user_stats', stats);
    } else {
      await db.update('user_stats', stats, where: 'id = ?', whereArgs: [existing['id']]);
    }
  }

  Future<Map<String, dynamic>?> getUserStats() async {
    final db = await database;
    final results = await db.query('user_stats', limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  // ✅ NEW: User profile methods
  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await database;
    final results = await db.query('user_profile', limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateUserProfile(Map<String, dynamic> profile) async {
    final db = await database;
    final existing = await getUserProfile();
    profile['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    
    if (existing == null) {
      return await db.insert('user_profile', profile);
    } else {
      return await db.update(
        'user_profile', 
        profile, 
        where: 'id = ?', 
        whereArgs: [existing['id']]
      );
    }
  }

  // Reset database method
  Future<void> resetDatabase() async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear all tables
      await txn.delete('food_entries');
      await txn.delete('passport_stamps');
      await txn.delete('user_stats');
      await txn.delete('user_profile'); // ✅ Added user_profile
      
      // Reinitialize with default user stats
      await txn.insert('user_stats', {
        'total_foods_tried': 0,
        'current_streak': 0,
        'best_streak': 0,
        'total_calories': 0.0,
        'last_entry_date': null,
      });
      
      // ✅ Reinitialize with default user profile
      await txn.insert('user_profile', {
        'name': null,
        'age': null,
        'allergies': '[]',
        'dietary_preference': null,
        'country': null,
        'language': null,
      });
    });
    print('✅ Database reset successfully');
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}