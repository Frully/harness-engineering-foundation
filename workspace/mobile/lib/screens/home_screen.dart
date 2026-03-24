import 'package:flutter/material.dart';

import '../types/auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user, required this.onLogout});

  final User user;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Text(
              'Mobile session restored.',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'The app recovered the current operator with the stored bearer token and the shared backend session table.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _MetricTile(label: 'Operator', value: user.email),
            const SizedBox(height: 12),
            const _MetricTile(
              label: 'Transport',
              value: 'Authorization Bearer',
            ),
            const SizedBox(height: 12),
            const _MetricTile(
              label: 'Session model',
              value: 'Shared opaque session',
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('logoutButton'),
              onPressed: () => onLogout(),
              child: const Text('Logout and clear bearer token'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF2),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
