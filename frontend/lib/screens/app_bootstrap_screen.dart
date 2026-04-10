import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_bootstrap_provider.dart';
import '../providers/auth_provider.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

class AppBootstrapScreen extends ConsumerWidget {
  const AppBootstrapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);
    final auth = ref.watch(authProvider);

    return bootstrap.when(
      data: (_) {
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

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
