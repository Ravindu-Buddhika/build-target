import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';

class GoalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> goal;
  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  
  Future<void> _toggleTaskStatus(int taskId, int currentStatus) async {
    final db = await DBHelper.database;
    int newStatus = currentStatus == 1 ? 0 : 1;

    await db.update(
      'Tasks',
      {'is_done': newStatus},
      where: 'id = ?',
      whereArgs: [taskId],
    );

    if (newStatus == 1) {
      // මෙතනදී ලැබෙන trophy එකේ නම අල්ලගන්නවා
      String? unlockedTrophy = await _updateStreakAndTrophies();
      
      if (unlockedTrophy != null && mounted) {
        _showTrophyPopup(unlockedTrophy);
      }

      final allTasks = await _fetchTasks();
      int doneCount = allTasks.where((t) => t['is_done'] == 1).length;

      if (doneCount == allTasks.length) {
        await db.execute('UPDATE Trophies SET ultimate_finisher_count = ultimate_finisher_count + 1 WHERE user_id = ?', [1]);
        _showSuccessDialog();
      }
    }

    setState(() {});
  }

  // මෙතන දැන් return type එක String? කළා අලුත් trophy එක UI එකට යවන්න
  Future<String?> _updateStreakAndTrophies() async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> userResult = await db.query('Users', limit: 1);
    
    if (userResult.isEmpty) return null;

    final user = userResult.first;
    String lastDateStr = user['last_activity_date'] ?? "";
    int currentStreak = user['current_streak'] ?? 0;
    int longestStreak = user['longest_streak'] ?? 0;

    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    if (lastDateStr == todayStr) return null;

    DateTime today = DateTime.parse(todayStr);
    bool isConsecutive = false;
    String? newTrophy;

    if (lastDateStr.isNotEmpty) {
      DateTime lastDate = DateTime.parse(lastDateStr);
      if (today.difference(lastDate).inDays == 1) {
        isConsecutive = true;
      }
    } else {
      isConsecutive = true;
    }

    if (isConsecutive) {
      currentStreak++;
    } else {
      currentStreak = 1;
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    await db.update('Users', {
      'last_activity_date': todayStr,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    }, where: 'id = ?', whereArgs: [user['id']]);

    // First Spark Trophy
    await db.execute('UPDATE Trophies SET first_spark_count = first_spark_count + 1 WHERE user_id = ?', [user['id']]);
    newTrophy = "First Spark";

    // Triple Threat
    if (currentStreak == 3) {
      await db.execute('UPDATE Trophies SET triple_threat_count = triple_threat_count + 1 WHERE user_id = ?', [user['id']]);
      newTrophy = "Triple Threat";
    }

    // Week Warrior
    if (currentStreak == 7) {
      await db.execute('UPDATE Trophies SET week_warrior_count = week_warrior_count + 1 WHERE user_id = ?', [user['id']]);
      newTrophy = "Week Warrior";
    }

    // Fortnight Force
    if (currentStreak == 14) {
      await db.execute('UPDATE Trophies SET fortnight_force_count = fortnight_force_count + 1 WHERE user_id = ?', [user['id']]);
      newTrophy = "Fortnight Force";
    }

    return newTrophy;
  }

  // --- Achievement Popup UI ---
  void _showTrophyPopup(String trophyName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A1A1A),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.redAccent, size: 80),
              const SizedBox(height: 15),
              const Text(
                "ACHIEVEMENT UNLOCKED!",
                style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              Text(
                trophyName,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("AWESOME", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteGoal(int goalId) async {
    final db = await DBHelper.database;
    await db.delete('Goals', where: 'id = ?', whereArgs: [goalId]);
    if (mounted) Navigator.pop(context);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Congratulations! 🎉", style: TextStyle(color: Colors.white)),
        content: const Text("You have completed this goal 100%. Keep it up!", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Awesome", style: TextStyle(color: Color(0xFFFFD700))),
          )
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTasks() async {
    final db = await DBHelper.database;
    return await db.query(
      'Tasks',
      where: 'goal_id = ?',
      whereArgs: [widget.goal['id']],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text("Delete Goal?", style: TextStyle(color: Colors.white)),
                  content: const Text("Are you sure you want to delete this goal and its tasks?", style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteGoal(widget.goal['id']);
                      },
                      child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          }

          final tasks = snapshot.data!;
          int doneCount = tasks.where((t) => t['is_done'] == 1).length;
          double progress = tasks.isEmpty ? 0 : (doneCount / tasks.length);

          return SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  widget.goal['goal_name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 15,
                        backgroundColor: Colors.white10,
                        color: Colors.redAccent,
                      ),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: tasks.map((task) {
                      return GestureDetector(
                        onTap: () => _toggleTaskStatus(task['id'], task['is_done']),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: task['is_done'] == 1
                                ? Colors.lightGreenAccent.withOpacity(0.8)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  task['task_title'],
                                  style: TextStyle(
                                    color: task['is_done'] == 1 ? Colors.black : Colors.white,
                                    decoration: task['is_done'] == 1 ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              Icon(
                                task['is_done'] == 1 ? Icons.check_circle : Icons.circle_outlined,
                                color: task['is_done'] == 1 ? Colors.black : Colors.white,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}