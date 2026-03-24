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
      title: 'Create account.',
      eyebrow: 'Create account',
      summary: 'Create your account to continue.',
      footerLabel: 'Already have an account?',
      footerAction: 'Sign in.',
      onSwitch: onSwitch,
      child: AuthForm(
        actionLabel: 'Create account',
        description: 'Enter your account details.',
        mode: AuthFormMode.register,
        onSubmit: onSubmit,
      ),
    );
  }
}
