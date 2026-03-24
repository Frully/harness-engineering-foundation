import 'package:flutter/material.dart';

import 'components/interface_theme.dart';
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
      theme: buildHarnessTheme(),
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
    return Scaffold(
      body: CommandShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CommandPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommandStrip(
                    items: ['BOOT', 'BEARER PROBE', 'SESSION RESTORE'],
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Restoring mobile bearer session...',
                    style: TextStyle(
                      fontSize: 40,
                      height: 0.94,
                      fontWeight: FontWeight.w700,
                      color: InterfacePalette.ink,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'The handheld shell is checking the persisted token and re-entering the shared server session ledger.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: InterfacePalette.inkSoft,
                    ),
                  ),
                  SizedBox(height: 22),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const CommandPanel(
              commandSurface: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommandStrip(
                    inverse: true,
                    items: ['MOBILE NODE', 'COMMAND READY'],
                  ),
                  SizedBox(height: 18),
                  LinearProgressIndicator(
                    minHeight: 10,
                    backgroundColor: Color.fromRGBO(247, 238, 221, 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      InterfacePalette.accentLight,
                    ),
                  ),
                ],
              ),
            ),
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
