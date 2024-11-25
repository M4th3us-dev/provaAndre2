import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prova2andre/firebase_options.dart';
import 'package:prova2andre/telas/auth/loginscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prova Andree',
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.dark,
      home: LoginScreen(),
    );
  }



  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blueAccent,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blueAccent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
      ),
    );
  }
}
