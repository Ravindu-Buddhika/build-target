import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure Black Background
      body: SafeArea(
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
                    color: const Color(0xFFE2E2BE), // Figma එකේ තියෙන Cream color එක
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
                                "Hello Amila",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Lets Achieve something",
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                          // Badge Image
                          Image.asset(
                            'assets/images/Elite_Master-removebg-preview.png',
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Stats Row (8, 2, 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem("8", "Stircke"), // Figma එකේ spelling Stircke නිසා ඒකම දැම්මා
                          _buildStatItem("2", "Active"),
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
                  children: [
                    _buildGoalCard("Fitness Up", 90),
                    const SizedBox(height: 15),
                    _buildGoalCard("Learning Java", 90),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating Action Button for Adding new targets
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFFD700), // Gold/Amber color
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  // Stat Item Builder
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ],
    );
  }

  // Goal Card Builder (Figma style)
  Widget _buildGoalCard(String title, int progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700), // Amber color
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          // Circular Progress Indicator with Percentage
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 45,
                height: 45,
                child: CircularProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.black12,
                  color: const Color(0xFF4CAF50), // Green color progress
                  strokeWidth: 4,
                ),
              ),
              Text(
                "$progress%",
                style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}