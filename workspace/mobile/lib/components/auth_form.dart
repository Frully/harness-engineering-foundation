import 'package:flutter/material.dart';

import 'interface_theme.dart';
import '../types/auth.dart';

enum AuthFormMode { login, register }

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.actionLabel,
    required this.description,
    required this.mode,
    required this.onSubmit,
  });

  final String actionLabel;
  final String description;
  final AuthFormMode mode;
  final Future<void> Function(Credentials credentials) onSubmit;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          confirmPassword: widget.mode == AuthFormMode.register
              ? _confirmPasswordController.text
              : null,
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
          Text(
            widget.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          const _FormStrip(
            items: ['OPERATOR ID', 'SECRET', 'CONTROLLED ENTRY'],
          ),
          const SizedBox(height: 18),
          _CommandField(
            key: const Key('emailField'),
            label: 'Email',
            meta: 'IDENTITY',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Email is required.'
                : null,
          ),
          const SizedBox(height: 16),
          _CommandField(
            key: const Key('passwordField'),
            label: 'Password',
            meta: 'SECRET',
            controller: _passwordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Password is required.';
              }
              if (widget.mode == AuthFormMode.register) {
                final registrationError = validateRegisterCredentials(
                  email: _emailController.text,
                  password: value,
                  confirmPassword: value,
                );
                if (registrationError == 'Passwords do not match.') {
                  return null;
                }
                return registrationError;
              }
              return null;
            },
          ),
          if (widget.mode == AuthFormMode.register) ...[
            const SizedBox(height: 16),
            _CommandField(
              key: const Key('confirmPasswordField'),
              label: 'Confirm password',
              meta: 'PARITY',
              controller: _confirmPasswordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password confirmation is required.';
                }
                if (_passwordController.text != value) {
                  return 'Passwords do not match.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: InterfacePalette.accentSoft,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: InterfacePalette.line),
              ),
              child: Text(
                passwordPolicyHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: InterfacePalette.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: InterfacePalette.error.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                _error!,
                key: const Key('errorBanner'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: InterfacePalette.error),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('submitButton'),
            onPressed: _submitting ? null : _handleSubmit,
            child: Text(
              _submitting ? 'Sending mobile signal...' : widget.actionLabel,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.58),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: InterfacePalette.line),
            ),
            child: Text(
              'The handheld console uses the same shared server session model as the web shell, but transports it through a persisted bearer token.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormStrip extends StatelessWidget {
  const _FormStrip({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Text(
              item,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(letterSpacing: 2.1),
            ),
          )
          .toList(),
    );
  }
}

class _CommandField extends StatelessWidget {
  const _CommandField({
    required Key key,
    required this.label,
    required this.meta,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
  }) : _fieldKey = key;

  final Key _fieldKey;
  final String label;
  final String meta;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHeader = constraints.maxWidth < 320;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            compactHeader
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: InterfacePalette.inkSoft),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        meta,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: InterfacePalette.inkSoft),
                      ),
                    ],
                  ),
            const SizedBox(height: 8),
            TextFormField(
              key: _fieldKey,
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(
                color: InterfacePalette.ink,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: obscureText ? '••••••••' : 'operator@harness.demo',
                hintStyle: const TextStyle(color: InterfacePalette.inkSoft),
                filled: true,
                fillColor: const Color.fromRGBO(255, 255, 255, 0.72),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: InterfacePalette.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: InterfacePalette.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: InterfacePalette.accentLight,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: InterfacePalette.error.withValues(alpha: 0.45),
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: InterfacePalette.error),
                ),
              ),
              validator: validator,
            ),
          ],
        );
      },
    );
  }
}
