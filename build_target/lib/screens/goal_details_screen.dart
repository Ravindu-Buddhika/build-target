import 'package:flutter/material.dart';
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

    // Logic to check if all tasks are completed
    if (newStatus == 1) {
      final allTasks = await _fetchTasks();
      int doneCount = allTasks.where((t) => t['is_done'] == 1).length;

      if (doneCount == allTasks.length) {
        _showSuccessDialog();
      }
    }

    setState(() {});
  }

  Future<void> _deleteGoal(int goalId) async {
    final db = await DBHelper.database;
    await db.delete('Goals', where: 'id = ?', whereArgs: [goalId]);
    if (mounted) {
      Navigator.pop(context); // Go back to Home Page after deletion
    }
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  task['task_title'],
                                  style: TextStyle(
                                    color: task['is_done'] == 1
                                        ? Colors.black
                                        : Colors.white,
                                    decoration: task['is_done'] == 1
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                task['is_done'] == 1
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: task['is_done'] == 1
                                    ? Colors.black
                                    : Colors.white,
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