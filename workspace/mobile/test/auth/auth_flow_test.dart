import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harness_mobile/main.dart';
import 'package:harness_mobile/services/auth_service.dart';
import 'package:harness_mobile/types/auth.dart';

void main() {
  testWidgets('auth login restores the authenticated mobile shell', (tester) async {
    await tester.pumpWidget(
      HarnessMobileApp(
        authGateway: _FakeAuthGateway(initialUser: null),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('emailField')), 'login@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'hunter2');
    await tester.tap(find.byKey(const Key('submitButton')));
    await tester.pumpAndSettle();

    expect(find.text('Mobile session restored.'), findsOneWidget);
    expect(find.text('login@example.com'), findsOneWidget);
  });

  testWidgets('auth register switches flow and restores the authenticated mobile shell', (tester) async {
    await tester.pumpWidget(
      HarnessMobileApp(
        authGateway: _FakeAuthGateway(initialUser: null),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('switchModeButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('emailField')), 'register@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'hunter2');
    await tester.tap(find.byKey(const Key('submitButton')));
    await tester.pumpAndSettle();

    expect(find.text('Mobile session restored.'), findsOneWidget);
    expect(find.text('register@example.com'), findsOneWidget);
  });

  testWidgets('auth logout returns to the login shell', (tester) async {
    await tester.pumpWidget(
      HarnessMobileApp(
        authGateway: _FakeAuthGateway(
          initialUser: User(
            id: 1,
            email: 'mobile@example.com',
            createdAt: DateTime(2026, 3, 24),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('logoutButton')));
    await tester.pumpAndSettle();

    expect(find.text('Return to the mobile console.'), findsOneWidget);
  });
}

class _FakeAuthGateway implements AuthGateway {
  _FakeAuthGateway({required this.initialUser});

  final User? initialUser;

  @override
  Future<User> getCurrentUser() async {
    if (initialUser == null) {
      throw ApiException('missing token');
    }
    return initialUser!;
  }

  @override
  Future<User> login(Credentials credentials) async => User(
        id: 2,
        email: credentials.email,
        createdAt: DateTime(2026, 3, 24),
      );

  @override
  Future<void> logout() async {}

  @override
  Future<User> register(Credentials credentials) async => User(
        id: 3,
        email: credentials.email,
        createdAt: DateTime(2026, 3, 24),
      );
}
