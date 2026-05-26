import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  Future<Map<String, dynamic>> _getAchievementData() async {
    final db = await DBHelper.database;
    // User ගේ විස්තර සහ Trophies count එක එක පාර ගන්නවා
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT Users.name, Users.current_level, Trophies.* FROM Users 
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
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              
              // --- Elite Master Section ---
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/Elite_Master-removebg-preview.png', 
                      height: 180,
                    ), 
                    const Text(
                      "Current Title", 
                      style: TextStyle(color: Colors.yellow, fontSize: 14, letterSpacing: 1),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data['current_level'] ?? "ELITE MASTER",
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
                // Expanded වෙනුවට මෙතනට Figma එකට ගැලපෙන fixed height එකක් දුන්නා
                height: 280, 
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2BE), // Home card එකේම පාට ලස්සනට ගැලපෙනවා
                  borderRadius: BorderRadius.circular(20), // පැති හතරම සමානව රවුම් කළා
                ),
                child: GridView.count(
                  crossAxisCount: 3, // පේළියකට 3 බැගින්
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 10,
                  padding: EdgeInsets.zero, // උඩ තිබ්බ අනවශ්‍ය හිස් ඉඩ අයින් කළා
                  physics: const NeverScrollableScrollPhysics(), // Card එක ඇතුළේ scroll වෙන එක නැවැත්තුවා
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
        // Trophies වලට රතු පාට Icon එක
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