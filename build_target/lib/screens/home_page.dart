import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Build Target'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView( // Screen එක මදි වුණොත් scroll කරන්න පුළුවන් වෙන්න
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'Welcome Back, Ravindu!',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            
            // ඔයාගේ ප්‍රධාන Badge එක
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/Elite_Master-removebg-preview .png',
                width: 180,
                height: 180,
              ),
            ),
            
            const SizedBox(height: 20),
            const Text(
              'Elite Master',
              style: TextStyle(color: Colors.amber, fontSize: 20, letterSpacing: 1.5),
            ),
            
            const SizedBox(height: 50),
            
            // ලස්සන Button එකක් (React වල button එකක් වගේ)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  print("View Tasks Clicked!");
                },
                child: const Text('View Daily Tasks', style: TextStyle(color: Colors.black, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}