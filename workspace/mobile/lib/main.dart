import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart';
import 'types/auth.dart';

void main() {
  runApp(HarnessMobileApp(authGateway: AuthService()));
}

class HarnessMobileApp extends StatefulWidget {
  const HarnessMobileApp({super.key, required this.authGateway});

  final AuthGateway authGateway;

  @override
  State<HarnessMobileApp> createState() => _HarnessMobileAppState();
}

class _HarnessMobileAppState extends State<HarnessMobileApp> {
  SessionView _sessionView = const SessionLoading();

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final user = await widget.authGateway.getCurrentUser();
      if (!mounted) {
        return;
      }
      setState(() {
        _sessionView = SessionAuthenticated(user);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _sessionView = const SessionAnonymous();
      });
    }
  }

  Future<void> _handleLogin(Credentials credentials) async {
    final user = await widget.authGateway.login(credentials);
    if (!mounted) {
      return;
    }
    setState(() {
      _sessionView = SessionAuthenticated(user);
    });
  }

  Future<void> _handleRegister(Credentials credentials) async {
    final user = await widget.authGateway.register(credentials);
    if (!mounted) {
      return;
    }
    setState(() {
      _sessionView = SessionAuthenticated(user);
    });
  }

  Future<void> _handleLogout() async {
    await widget.authGateway.logout();
    if (!mounted) {
      return;
    }
    setState(() {
      _sessionView = const SessionAnonymous();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harness Mobile Console',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAD5B2C),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4EBDD),
        textTheme: ThemeData.light().textTheme.copyWith(
          displayMedium: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w600,
            color: Color(0xFF221A16),
            height: 1.05,
          ),
        ),
      ),
      home: switch (_sessionView) {
        SessionLoading() => const LoadingScreen(),
        SessionAnonymous() => AuthFlow(
          onLogin: _handleLogin,
          onRegister: _handleRegister,
        ),
        SessionAuthenticated(:final user) => HomeScreen(
          user: user,
          onLogout: _handleLogout,
        ),
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Restoring mobile bearer session...'),
          ],
        ),
      ),
    );
  }
}

sealed class SessionView {
  const SessionView();
}

class SessionLoading extends SessionView {
  const SessionLoading();
}

class SessionAnonymous extends SessionView {
  const SessionAnonymous();
}

class SessionAuthenticated extends SessionView {
  const SessionAuthenticated(this.user);

  final User user;
}

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key, required this.onLogin, required this.onRegister});

  final Future<void> Function(Credentials credentials) onLogin;
  final Future<void> Function(Credentials credentials) onRegister;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: showLogin
          ? LoginScreen(
              key: const ValueKey('login'),
              onSubmit: widget.onLogin,
              onSwitch: () => setState(() => showLogin = false),
            )
          : RegisterScreen(
              key: const ValueKey('register'),
              onSubmit: widget.onRegister,
              onSwitch: () => setState(() => showLogin = true),
            ),
    );
  }
}
