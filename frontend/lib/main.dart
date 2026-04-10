import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'screens/app_bootstrap_screen.dart';

void main() {
  runApp(const ProviderScope(child: PosApp()));
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppBootstrapScreen(),
    );
  }
}
