import 'package:flutter/material.dart';

import 'interface_theme.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.summary,
    required this.footerLabel,
    required this.footerAction,
    required this.onSwitch,
    required this.child,
  });

  final String title;
  final String eyebrow;
  final String summary;
  final String footerLabel;
  final String footerAction;
  final VoidCallback onSwitch;
  final Widget child;

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
                  const CommandStrip(
                    items: ['SESSION ENTRY', 'MOBILE NODE', 'ACCOUNT ACCESS'],
                  ),
                  const SizedBox(height: 18),
                  Text(eyebrow, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 12),
                  Text(title, style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 14),
                  Text(summary, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 18),
                  const SignalRail(
                    items: ['Shared session', 'Phone ready', 'Smoke visible'],
                  ),
                  const SizedBox(height: 18),
                  child,
                  const SizedBox(height: 18),
                  TextButton(
                    key: const Key('switchModeButton'),
                    onPressed: onSwitch,
                    child: Text('$footerLabel $footerAction'),
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
