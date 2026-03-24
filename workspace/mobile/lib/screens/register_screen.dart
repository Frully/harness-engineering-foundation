import 'package:flutter/material.dart';

import '../components/auth_form.dart';
import '../components/auth_scaffold.dart';
import '../types/auth.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({
    super.key,
    required this.onSubmit,
    required this.onSwitch,
  });

  final Future<void> Function(Credentials credentials) onSubmit;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Provision a mobile operator.',
      eyebrow: 'Session mint',
      footerLabel: 'Already provisioned?',
      footerAction: 'Go back to login',
      onSwitch: onSwitch,
      child: AuthForm(
        actionLabel: 'Register and issue bearer token',
        description:
            'Registration creates the shared server-side session and returns a bearer token for Flutter to persist.',
        mode: AuthFormMode.register,
        onSubmit: onSubmit,
      ),
    );
  }
}
