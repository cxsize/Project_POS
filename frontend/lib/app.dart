import 'package:flutter/material.dart';

import 'screens/startup_screen.dart';

class ProjectPosApp extends StatelessWidget {
  const ProjectPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B5A),
          brightness: Brightness.light,
          surface: const Color(0xFFF4F1EA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F1EA),
        useMaterial3: true,
      ),
      home: const StartupScreen(),
    );
  }
}
