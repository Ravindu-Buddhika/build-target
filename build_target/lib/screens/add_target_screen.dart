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

  Future<void> _handleBuildPlan() async {

    if (_targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your target first!")),
      );
      return;
    }


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );

    try {

      List<String> planSteps = await AIService.generatePlan(
        target: _targetController.text,
        duration: _selectedWeeks.toInt().toString(),
        level: _selectedLevel,
        description: _descController
            .text,
      );

      if (planSteps.isNotEmpty) {
        final db = await DBHelper.database;

  
        int goalId = await db.insert('Goals', {
          'user_id': 1, 
          'goal_name': _targetController.text,
          'full_plan_content': planSteps.join(
            ', ',
          ),
        });


        for (var step in planSteps) {
          await db.insert('Tasks', {
            'goal_id': goalId,
            'task_title': step, 
            'week_number': 1, 
            'day_number': 1, 
            'task_desc': step,
            'is_done': 0,
          });
        }

        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {

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
                  onPressed: _handleBuildPlan,
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
