import 'package:flutter/material.dart';

import '../models/app_environment.dart';
import '../widgets/checklist_card.dart';
import '../widgets/module_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideLayout = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project POS',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF16302B),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sprint 1 scaffold is ready for auth, local models, and checkout flows.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF42534F),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (isWideLayout)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: const [
                                ModuleCard(
                                  title: 'Core Checkout Engine',
                                  description:
                                      'Tablet-first shell, Riverpod state container, and service boundaries for the POS flow.',
                                ),
                                SizedBox(height: 16),
                                ModuleCard(
                                  title: 'Offline-First Foundation',
                                  description:
                                      'Env loading and local database bootstrap are wired so POS-12 can register Isar collections next.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ChecklistCard(environment: environment),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const ModuleCard(
                            title: 'Core Checkout Engine',
                            description:
                                'Tablet-first shell, Riverpod state container, and service boundaries for the POS flow.',
                          ),
                          const SizedBox(height: 16),
                          const ModuleCard(
                            title: 'Offline-First Foundation',
                            description:
                                'Env loading and local database bootstrap are wired so POS-12 can register Isar collections next.',
                          ),
                          const SizedBox(height: 16),
                          ChecklistCard(environment: environment),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
