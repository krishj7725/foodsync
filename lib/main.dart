import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_screen.dart'; // Links to your Navigator

void main() {
  // 1. Wrap the entire app in ProviderScope so Riverpod works
  runApp(const ProviderScope(child: FoodSyncApp()));
}

class FoodSyncApp extends StatelessWidget {
  const FoodSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the "Debug" banner
      title: 'FoodSync',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50], // Clean light background
        
        // Define the Global Color Scheme (Black & White Theme)
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
          secondary: Colors.white,
          surface: Colors.white,
        ),
        
        // Style the AppBars globally
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent, // Removes scroll color tint
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w800, // Extra Bold Titles
          ),
        ),
        
        // Style the Text Fields globally
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
      ),
      // 2. Point to the MainScreen (The Navigator)
      home: const MainScreen(),
    );
  }
}