import 'package:flutter/material.dart';
import '../database/db_helper.dart'; // DBHelper එක import කරන්න
import 'package:build_target/screens/add_target_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Database එකෙන් දත්ත ලබාගන්නා Function එක
  Future<Map<String, dynamic>> _fetchHomeData() async {
    final db = await DBHelper.database;
    final userList = await db.query('Users', limit: 1);
    final goalsList = await db.query('Goals');

    // හැම Goal එකකටම අදාළ progress එක ගණනය කරමු
    List<Map<String, dynamic>> goalsWithProgress = [];
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
      }

      var goalMap = Map<String, dynamic>.from(goal);
      goalMap['computed_progress'] = progress.toInt();
      goalsWithProgress.add(goalMap);
    }

    return {
      'user': userList.isNotEmpty ? userList.first : null,
      'goals': goalsWithProgress,
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

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // --- Upper Profile Card Section ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                    "Hello ${user['name']}", // Database එකෙන් නම එනවා
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem("8", "Stircke"),
                              _buildStatItem(
                                goals.length.toString(),
                                "Active",
                              ), // Dynamic count
                              _buildStatItem("1", "Done"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Ongoing Goals Section ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: goals.map((goal) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _buildGoalCard(
                            goal['goal_name'],
                            goal['computed_progress'],
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
            // AddTargetScreen එකෙන් පස්සට (Back) ආපු ගමන් මේක වැඩ කරනවා
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

  Widget _buildGoalCard(String title, int progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
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
    );
  }
}
