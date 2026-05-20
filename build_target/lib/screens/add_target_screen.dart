import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class AddTargetScreen extends StatefulWidget {
  const AddTargetScreen({super.key});

  @override
  State<AddTargetScreen> createState() => _AddTargetScreenState();
}

class _AddTargetScreenState extends State<AddTargetScreen> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  double _selectedWeeks = 1;
  String _selectedLevel = 'Beginner';

  // Database එකට Save කරන Function එක
  Future<void> _saveTarget() async {
    if (_targetController.text.isEmpty) return;

    final db = await DBHelper.database;
    
    // 1. Goal එක Save කිරීම
    int goalId = await db.insert('Goals', {
      'user_id': 1, // දැනට 1 ලෙස ගමු
      'goal_name': _targetController.text,
      'full_plan_content': _descController.text,
      'status': 'active'
    });

    // 2. පස්සේ අපි මෙතනදී Gemini AI එක පාවිච්චි කරලා Tasks Generate කරමු
    // දැනට Sample task එකක් දාමු වැඩේ චෙක් කරන්න
    await db.insert('Tasks', {
      'goal_id': goalId,
      'task_title': 'First Step of ${_targetController.text}',
      'week_number': 1,
      'day_number': 1,
      'task_desc': 'Get started with the basics',
      'is_done': 0
    });

    if (mounted) Navigator.pop(context); // ඉවර වුණාම ආපහු Home එකට යන්න
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("1 Week", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  Text("2 Weeks", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  Text("3 Weeks", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  Text("4 Weeks", style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),

              const SizedBox(height: 25),
              _buildLabel("Your Level"),
              _buildDropdown(),

              const SizedBox(height: 25),
              _buildLabel("Explain your Target with your words"),
              _buildTextField(_descController, "I want to learn...", maxLines: 5),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _saveTarget,
                  child: const Text("Build My Plan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(10)),
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