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
      title: 'Sign in.',
      eyebrow: 'Sign in',
      summary: 'Use your account to continue.',
      footerLabel: 'Need an account?',
      footerAction: 'Create one.',
      onSwitch: onSwitch,
      child: AuthForm(
        actionLabel: 'Sign in',
        mode: AuthFormMode.login,
        onSubmit: onSubmit,
      ),
    );
  }
}
