import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.footerLabel,
    required this.footerAction,
    required this.onSwitch,
    required this.child,
  });

  final String title;
  final String eyebrow;
  final String footerLabel;
  final String footerAction;
  final VoidCallback onSwitch;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6EEDD), Color(0xFFE8DDD0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  color: const Color(0xFFFFFAF2),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          eyebrow,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                letterSpacing: 2.4,
                                color: const Color(0xFF70594E),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(title, style: Theme.of(context).textTheme.displayMedium),
                        const SizedBox(height: 24),
                        child,
                        const SizedBox(height: 20),
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
          ),
        ),
      ),
    );
  }
}
