import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../widgets/status_panel.dart';
import 'home_screen.dart';

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(startupProvider);

    return startup.when(
      data: (environment) => HomeScreen(environment: environment),
      loading: () => const Scaffold(
        body: Center(
          child: StatusPanel(
            title: 'Preparing terminal',
            message: 'Loading environment config and local database bootstrap.',
            isLoading: true,
          ),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: StatusPanel(
            title: 'Startup failed',
            message: error.toString(),
          ),
        ),
      ),
    );
  }
}
