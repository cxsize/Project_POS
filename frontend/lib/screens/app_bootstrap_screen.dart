import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_bootstrap_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/service_providers.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

class AppBootstrapScreen extends ConsumerStatefulWidget {
  const AppBootstrapScreen({super.key});

  @override
  ConsumerState<AppBootstrapScreen> createState() => _AppBootstrapScreenState();
}

class _AppBootstrapScreenState extends ConsumerState<AppBootstrapScreen> {
  bool _syncStarted = false;

  @override
  void dispose() {
    if (_syncStarted) {
      ref.read(offlineSyncServiceProvider).stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final bootstrap = ref.watch(appBootstrapProvider);
    final auth = ref.watch(authProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (auth.isAuthenticated) {
        final offlineSyncService = ref.read(offlineSyncServiceProvider);
        offlineSyncService.start();
        _syncStarted = true;
      } else if (_syncStarted) {
        final offlineSyncService = ref.read(offlineSyncServiceProvider);
        offlineSyncService.stop();
        _syncStarted = false;
      }
    });

    return bootstrap.when(
      data: (_) {
        if (!auth.isAuthenticated) {
          unawaited(ref.read(offlineSyncServiceProvider).stop());
          return const LoginScreen();
        }

        unawaited(ref.read(offlineSyncServiceProvider).start());
        if (auth.user?.role == 'cashier') {
          return const CheckoutScreen();
        }

        return const OrderHistoryScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'App startup failed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
