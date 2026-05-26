import '../database/db_helper.dart';

class XPService {
  // Task එකක් Done කරද්දී දෙන XP ගණන
  static const int taskXp = 10;
  
  // Goal එකක් 100% ඉවර කරද්දී දෙන XP ගණන
  static const int goalCompletionXp = 50;

  // අලුතින් Goal එකක් හදද්දී දෙන XP ගණන (උදා: 20)
  static const int goalCreationXp = 20;

  static Future<void> addXP(int amount) async {
    final db = await DBHelper.database;
    
    final List<Map<String, dynamic>> users = await db.query('Users', limit: 1);
    if (users.isEmpty) return;

    int currentXp = users.first['total_xp'] ?? 0;
    int newXp = currentXp + amount;

    await db.update(
      'Users',
      {'total_xp': newXp},
      where: 'id = ?',
      whereArgs: [users.first['id']],
    );
    
    print("XP Added: $amount | New Total: $newXp");
  }
}