import 'package:flutter/material.dart';
import './database/db_helper.dart';
import './screens/home_page.dart';
import './screens/name_input_screen.dart'; // ඔයා මේ Screen එක හදන file එකේ path එක දෙන්න

void main() async {
  // Flutter bindings initialize කිරීම අනිවාර්යයි
  WidgetsFlutterBinding.ensureInitialized();
  
  // Database එක check කරලා බලනවා user කෙනෙක් ඉන්නවද කියලා
  final db = await DBHelper.database;
  final List<Map<String, dynamic>> users = await db.query('Users');

  // User නැත්නම් NameInputScreen එකට යවනවා
  Widget initialScreen = users.isEmpty ? const NameInputScreen() : const HomePage();

  runApp(MyApp(startScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;
  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Build Target',
      theme: ThemeData(brightness: Brightness.dark),
      home: startScreen, 
    );
  }
}