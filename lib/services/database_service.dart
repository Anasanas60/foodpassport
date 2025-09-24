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
      version: 1,
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
    await db.insert(
      'user_stats',
      stats,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserStats() async {
    final db = await database;
    final results = await db.query('user_stats', limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}