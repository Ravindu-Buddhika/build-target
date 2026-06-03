import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  // XP අනුව Title එක සහ Image එක තීරණය කරන Helper Function එක
  Map<String, String> _getLevelData(int xp) {
    if (xp >= 5000) {
      return {
        'name': 'MYTHIC LEGEND',
        'image': 'assets/images/Mythic_Legend-removebg-preview.png'
      };
    } else if (xp >= 2500) {
      return {
        'name': 'ELITE MASTER',
        'image': 'assets/images/Elite_Master-removebg-preview.png'
      };
    } else if (xp >= 1200) {
      return {
        'name': 'PLATINUM COMMANDER',
        'image': 'assets/images/Platinum_Commander-removebg-preview.png'
      };
    } else if (xp >= 500) {
      return {
        'name': 'GOLD VETERAN',
        'image': 'assets/images/Gold_Veteran-removebg-preview.png'
      };
    } else if (xp >= 100) {
      return {
        'name': 'SILVER SCOUT',
        'image': 'assets/images/Silver_Scout-removebg-preview.png'
      };
    } else {
      return {
        'name': 'BRONZE RECRUIT',
        'image': 'assets/images/Bronze_Recruit-removebg-preview.png'
      };
    }
  }

  Future<Map<String, dynamic>> _getAchievementData() async {
    final db = await DBHelper.database;
    // Users table එකෙන් total_xp අගයත් එක්කම දත්ත ලබාගන්නවා
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT Users.name, Users.total_xp, Trophies.* FROM Users 
      JOIN Trophies ON Users.id = Trophies.user_id 
      WHERE Users.id = 1
    ''');
    return result.isNotEmpty ? result.first : {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Trophy Cabinet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getAchievementData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No Data Found", style: TextStyle(color: Colors.white)),
            );
          }

          final data = snapshot.data!;
          final int totalXp = data['total_xp'] ?? 0;
          final levelData = _getLevelData(totalXp);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              
              // --- Dynamic Level Section ---
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      levelData['image']!, 
                      height: 180,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.workspace_premium, size: 100, color: Colors.amber),
                    ), 
                    const Text(
                      "Current Title", 
                      style: TextStyle(color: Colors.yellow, fontSize: 14, letterSpacing: 1),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      levelData['name']!,
                      style: const TextStyle(
                        color: Colors.yellow, 
                        fontSize: 26, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 35),

              // --- Trophy Cabinet Card ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                height: 280, 
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2BE), 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GridView.count(
                  crossAxisCount: 3, 
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 10,
                  padding: EdgeInsets.zero, 
                  physics: const NeverScrollableScrollPhysics(), 
                  children: [
                    _buildTrophyItem("First Spark", data['first_spark_count'] ?? 0),
                    _buildTrophyItem("Triple Threat", data['triple_threat_count'] ?? 0),
                    _buildTrophyItem("Week Warrior", data['week_warrior_count'] ?? 0),
                    _buildTrophyItem("Fortnight Force", data['fortnight_force_count'] ?? 0),
                    _buildTrophyItem("Ultimate Finisher", data['ultimate_finisher_count'] ?? 0),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrophyItem(String name, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.emoji_events, color: Colors.redAccent, size: 45), 
        const SizedBox(height: 6),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black, 
            fontSize: 11, 
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "x$count",
          style: const TextStyle(
            color: Colors.black, 
            fontSize: 13, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}