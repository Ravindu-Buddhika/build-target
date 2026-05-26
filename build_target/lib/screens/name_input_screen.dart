import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'home_page.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _saveUser() async {
    if (_nameController.text.trim().isEmpty) return;

    final db = await DBHelper.database;
    
    // User ව insert කරනවා (XP 0 සහ Starting Level එක 'NOVICE' විදිහට)
    int userId = await db.insert('Users', {
      'name': _nameController.text.trim(),
      'current_level': 'NOVICE', 
      'total_xp': 0,
      'last_activity_date': '',
      'current_streak': 0,
      'longest_streak': 0,
    });

    // ඒ user ට අදාළ trophy record එකක් හදනවා
    await db.insert('Trophies', {'user_id': userId});

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // මුළු Background එකම කළු පාටයි
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon එකට රන්වන් පාට (Colors.amber) එකතු කළා
            const Icon(Icons.psychology, color: Colors.amber, size: 100),
            const SizedBox(height: 30),
            
            const Text(
              "WELCOME TO BUILD TARGET",
              style: TextStyle(
                color: Colors.white, 
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 2
              ),
            ),
            const SizedBox(height: 10),
            
            const Text(
              "What should we call you?", 
              style: TextStyle(color: Colors.white70)
            ),
            const SizedBox(height: 30),
            
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.amber, // Type කරන කොට එන ඉරත් Amber කළා
              decoration: InputDecoration(
                hintText: "Enter your name...",
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white10,
                // Input එක click කළාම එන Border එකත් Amber කළා
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.amber, width: 1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), 
                  borderSide: BorderSide.none
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Button එක සම්පූර්ණයෙන්ම Amber තේමාවට
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700), // ඔයා ඉල්ලපු රන්වන් පාට
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                  ),
                ),
                onPressed: _saveUser,
                child: const Text(
                  "START JOURNEY", 
                  style: TextStyle(
                    color: Colors.black, // රන්වන් පාට උඩ කළු පාට අකුරු හොඳට පේනවා
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}