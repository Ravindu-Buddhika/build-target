import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'build_target.db');
    
    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // 1. Users Table (Added Streak and Activity Tracking)
        await db.execute('''
          CREATE TABLE Users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            current_level TEXT,
            total_xp INTEGER,
            last_activity_date TEXT, -- YYYY-MM-DD
            current_streak INTEGER DEFAULT 0,
            longest_streak INTEGER DEFAULT 0
          )
        ''');

        // 2. Goals Table
        await db.execute('''
          CREATE TABLE Goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            goal_name TEXT,
            full_plan_content TEXT,
            status TEXT,
            FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE
          )
        ''');

        // 3. Tasks Table
        await db.execute('''
          CREATE TABLE Tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            goal_id INTEGER,
            task_title TEXT,
            week_number INTEGER,
            day_number INTEGER,
            task_desc TEXT,
            is_done INTEGER DEFAULT 0,
            FOREIGN KEY (goal_id) REFERENCES Goals (id) ON DELETE CASCADE
          )
        ''');

        // 4. Trophies Table (Count-based tracking for the Cabinet)
        await db.execute('''
          CREATE TABLE Trophies (
            user_id INTEGER PRIMARY KEY,
            first_spark_count INTEGER DEFAULT 0,
            triple_threat_count INTEGER DEFAULT 0,
            week_warrior_count INTEGER DEFAULT 0,
            fortnight_force_count INTEGER DEFAULT 0,
            ultimate_finisher_count INTEGER DEFAULT 0,
            FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE
          )
        ''');

        // --- Initial Data Setup ---
        
        int userId = await db.insert('Users', {
          'name': 'Ravindu',
          'current_level': 'Elite Master',
          'total_xp': 1250,
          'last_activity_date': '', // Initially empty
          'current_streak': 0,
          'longest_streak': 0,
        });

        await db.insert('Trophies', {'user_id': userId});

        // Dummy Goal and Task for testing
        int goalId = await db.insert('Goals', {
          'user_id': userId,
          'goal_name': 'Learning Java',
          'full_plan_content': '{"description": "Master Spring Boot and JPA"}',
          'status': 'active'
        });

        await db.insert('Tasks', {
          'goal_id': goalId,
          'task_title': 'Setup Environment',
          'week_number': 1,
          'day_number': 1,
          'task_desc': 'Install JDK and IntelliJ IDEA',
          'is_done': 0 // Keeping it 0 so you can test checking it
        });
      },
    );
  }
}