import 'package:flutter/material.dart';

import '../types/auth.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.actionLabel,
    required this.description,
    required this.onSubmit,
  });

  final String actionLabel;
  final String description;
  final Future<void> Function(Credentials credentials) onSubmit;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.onSubmit(
        Credentials(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          TextFormField(
            key: const Key('emailField'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Email is required.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('passwordField'),
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Password is required.' : null,
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B311D).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(_error!, key: const Key('errorBanner')),
            ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('submitButton'),
            onPressed: _submitting ? null : _handleSubmit,
            child: Text(_submitting ? 'Sending mobile signal...' : widget.actionLabel),
          ),
        ],
      ),
    );
  }
}
