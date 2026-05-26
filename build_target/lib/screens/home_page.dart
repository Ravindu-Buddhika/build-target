import 'package:flutter/material.dart';
import '../database/db_helper.dart'; 
import 'package:build_target/screens/add_target_screen.dart';
import 'goal_details_screen.dart';
import 'achievement_screen.dart'; // Trophy Cabinet screen එක import කරගන්න

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Map<String, dynamic>> _fetchHomeData() async {
    final db = await DBHelper.database;
    final userList = await db.query('Users', limit: 1);
    final goalsList = await db.query('Goals');

    List<Map<String, dynamic>> goalsWithProgress = [];
    int totalDoneGoals = 0;

    for (var goal in goalsList) {
      final tasks = await db.query(
        'Tasks',
        where: 'goal_id = ?',
        whereArgs: [goal['id']],
      );

      double progress = 0;
      if (tasks.isNotEmpty) {
        int doneTasks = tasks.where((t) => t['is_done'] == 1).length;
        progress = (doneTasks / tasks.length) * 100;
        
        if (progress == 100) totalDoneGoals++;
      }

      var goalMap = Map<String, dynamic>.from(goal);
      goalMap['computed_progress'] = progress.toInt();
      goalsWithProgress.add(goalMap);
    }

    return {
      'user': userList.isNotEmpty ? userList.first : null,
      'goals': goalsWithProgress,
      'doneCount': totalDoneGoals,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchHomeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (!snapshot.hasData || snapshot.data!['user'] == null) {
            return const Center(
              child: Text(
                "No User Data Found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final user = snapshot.data!['user'];
          final goals = snapshot.data!['goals'] as List<Map<String, dynamic>>;
          final doneCount = snapshot.data!['doneCount'];
          
          // DB එකෙන් dynamic ව එන current streak එක ගන්නවා (නැත්නම් 0)
          final currentStreak = user['current_streak']?.toString() ?? "0";

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        // Hero Section එක ක්ලික් කරාම Trophy Cabinet එකට යනවා
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AchievementScreen()),
                        ).then((_) {
                          // Cabinet එකේ ඉඳන් ආපහු එද්දී home එක refresh වෙන්න
                          setState(() {});
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E2BE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Hello ${user['name']}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Lets Achieve something",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Image.asset(
                                  'assets/images/Elite_Master-removebg-preview.png',
                                  width: 100,
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 50),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // මෙතනට dynamic streak එක පාස් කළා
                                _buildStatItem(currentStreak, "Strike"),
                                _buildStatItem(goals.length.toString(), "Active"),
                                _buildStatItem(doneCount.toString(), "Done"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: goals.map((goal) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _buildGoalCard(
                            goal,
                            goal['computed_progress'] ?? 0,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTargetScreen()),
          ).then((_) {
            setState(() {});
          });
        },
        backgroundColor: const Color(0xFFFFD700),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal, int progress) {
    return Dismissible(
      key: Key(goal['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent, 
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) async {
        final db = await DBHelper.database;
        await db.delete('Goals', where: 'id = ?', whereArgs: [goal['id']]);
        setState(() {}); 
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoalDetailsScreen(goal: goal),
            ),
          ).then((_) => setState(() {}));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal['goal_name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.black12,
                      color: const Color(0xFF4CAF50),
                      strokeWidth: 4,
                    ),
                  ),
                  Text(
                    "$progress%",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}