import 'package:flutter/material.dart';
import 'screens/feedback_screen.dart';

void main() {
  runApp(const FeedbackApp());
}

class FeedbackApp extends StatelessWidget {
  const FeedbackApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Feedback Center',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3:
              false, // Switch to Material 2 temporarily to diagnose icons
          primarySwatch: Colors.blue,
          // Ensure material icons font is properly initialized
          iconTheme: const IconThemeData(
            color: Colors.black87,
            size: 24.0,
          ),
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.blue,
            iconTheme: const IconThemeData(color: Colors.white),
            toolbarTextStyle:
                const TextStyle(color: Colors.white, fontSize: 20),
            titleTextStyle: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        home: const FeedbackScreen(),
      );
}
