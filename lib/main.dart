
/**
 * @file Main entry point for the Illit app
 * @description
 * This file initializes the Flutter application, sets up the app theme,
 * and defines the initial screen (WelcomeScreen).
 *
 * Key features:
 * - Configures the MaterialApp with a custom light theme
 * - Sets WelcomeScreen as the home screen
 *
 * @dependencies
 * - flutter/material.dart: For MaterialApp and theme configuration
 * - screens/welcome_screen.dart: For the WelcomeScreen widget
 *
 * @notes
 * - The theme uses a custom color scheme consistent with the app's branding
 * - All screen logic has been moved to separate files for modularity
 */

import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const IllitApp());
}

class IllitApp extends StatelessWidget {
  const IllitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFFF8C1CC), // Rosa suave
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Fundo claro
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB2EBF2), // Azul claro
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ).copyWith(
            overlayColor: MaterialStateProperty.all(Colors.pink.withOpacity(0.2)),
          ),
        ),
      ),
      home: const WelcomeScreen(), // Define a tela inicial
    );
  }
}
