import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../services/ai_service.dart';

class AddTargetScreen extends StatefulWidget {
  const AddTargetScreen({super.key});

  @override
  State<AddTargetScreen> createState() => _AddTargetScreenState();
}

class _AddTargetScreenState extends State<AddTargetScreen> {
  // Controller names නිවැරදිව define කිරීම
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  double _selectedWeeks = 1;
  String _selectedLevel = 'Beginner';

  // AI ප්ලෑන් එක හදලා Database එකට Save කරන ප්‍රධාන Function එක
  Future<void> _handleBuildPlan() async {
    // Target එක හිස් නම් ඉදිරියට යන්න එපා
    if (_targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your target first!")),
      );
      return;
    }

    // 1. Loading Dialog එක පෙන්වීම
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );

    try {
      // 2. AI Service එක හරහා ප්ලෑන් එක ලබා ගැනීම
      List<String> planSteps = await AIService.generatePlan(
        target: _targetController.text,
        duration: _selectedWeeks.toInt().toString(),
        level: _selectedLevel,
        description: _descController
            .text, // මෙතන '_descController' නිවැරදිව පාවිච්චි කර ඇත
      );

      if (planSteps.isNotEmpty) {
        final db = await DBHelper.database;

        // 3. Goals Table එකට දත්ත ඇතුළත් කිරීම
        int goalId = await db.insert('Goals', {
          'user_id': 1, // දැනට default 1 ලෙස ගමු
          'goal_name': _targetController.text,
          'full_plan_content': planSteps.join(
            ', ',
          ), // සම්පූර්ණ ප්ලෑන් එක string එකක් ලෙස
        });

        // 4. Tasks Table එකට AI එකෙන් ආපු හැම Step එකක්ම ඇතුළත් කිරීම
        for (var step in planSteps) {
          await db.insert('Tasks', {
            'goal_id': goalId,
            'task_title': step, // 'task_name' වෙනුවට 'task_title' ලෙස වෙනස් කරන්න
            'week_number': 1, // මෙන්න මේ අලුත් පේළි ටිකත් එක් කරන්න
            'day_number': 1, // මොකද ඔයාගේ DB එකේ මේවා null වෙන්න බැරි වෙන්න ඇති
            'task_desc': step,
            'is_done': 0,
          });
        }

        // සාර්ථක නම් Screen එකෙන් ඉවත් වීම
        if (mounted) {
          Navigator.pop(context); // Loading එක close කරන්න
          Navigator.pop(context); // Home එකට යන්න
        }
      } else {
        // ප්ලෑන් එක ආවේ නැත්නම් loading එක අයින් කර error එකක් පෙන්වන්න
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to generate plan. Please try again."),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint("Error in AddTarget: $e");
    }
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Your target"),
              _buildTextField(_targetController, "Enter your goal..."),

              const SizedBox(height: 25),
              _buildLabel("Your Time"),
              Slider(
                value: _selectedWeeks,
                min: 1,
                max: 4,
                divisions: 3,
                activeColor: const Color(0xFFFFD700),
                label: "${_selectedWeeks.toInt()} Weeks",
                onChanged: (value) => setState(() => _selectedWeeks = value),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "1 Week",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Text(
                    "2 Weeks",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Text(
                    "3 Weeks",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Text(
                    "4 Weeks",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              _buildLabel("Your Level"),
              _buildDropdown(),

              const SizedBox(height: 25),
              _buildLabel("Explain your Target with your words"),
              _buildTextField(
                _descController,
                "I want to learn...",
                maxLines: 5,
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _handleBuildPlan, // මෙතනදී AI function එක call වේ
                  child: const Text(
                    "Build My Plan",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: _selectedLevel,
        dropdownColor: const Color(0xFF1E1E1E),
        isExpanded: true,
        underline: const SizedBox(),
        items: ['Beginner', 'Intermediate', 'Expert'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedLevel = value!),
      ),
    );
  }
}
