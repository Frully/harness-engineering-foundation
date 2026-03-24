import 'package:flutter/material.dart';

import '../components/auth_form.dart';
import '../components/auth_scaffold.dart';
import '../types/auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.onSubmit,
    required this.onSwitch,
  });

  final Future<void> Function(Credentials credentials) onSubmit;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Return to the mobile console.',
      eyebrow: 'Mobile bearer flow',
      footerLabel: 'Need an account?',
      footerAction: 'Create one now',
      onSwitch: onSwitch,
      child: AuthForm(
        actionLabel: 'Login with bearer token',
        description:
            'Flutter persists a bearer token locally, then restores the shared session with GET /api/me on launch.',
        onSubmit: onSubmit,
      ),
    );
  }
}
