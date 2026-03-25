import 'package:flutter/material.dart';

import '../components/interface_theme.dart';
import '../types/auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user, required this.onLogout});

  final User user;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommandShell(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: CommandPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Session restored.',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Your account is active in this browser.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.46),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: InterfacePalette.lineStrong),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Signed in as',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    key: const Key('logoutButton'),
                    onPressed: () => onLogout(),
                    child: const Text('Log out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
