import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harness_mobile/main.dart';
import 'package:harness_mobile/services/auth_service.dart';
import 'package:integration_test/integration_test.dart';
import '../../test/support/viewports.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('auth smoke register enters the authenticated mobile shell', (
    tester,
  ) async {
    await withSurfaceViewport(binding, phonePrimaryIosViewport);
    final email = smokeEmail('register');
    final tokenStore = InMemoryTokenStore();

    await pumpMobileApp(tester, tokenStore);
    await registerThroughUi(tester, email);

    await expectAuthenticatedShell(tester, email);
  });

  testWidgets('auth smoke restore keeps the bearer session after app restart', (
    tester,
  ) async {
    await withSurfaceViewport(binding, phonePrimaryIosViewport);
    final email = smokeEmail('restore');
    final tokenStore = InMemoryTokenStore();

    await pumpMobileApp(tester, tokenStore);
    await registerThroughUi(tester, email);
    await expectAuthenticatedShell(tester, email);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await pumpMobileApp(tester, tokenStore);
    await expectAuthenticatedShell(tester, email);
  });

  testWidgets(
    'auth smoke login re-enters the authenticated mobile shell after logout',
    (tester) async {
      await withSurfaceViewport(binding, phonePrimaryIosViewport);
      final email = smokeEmail('login');
      final tokenStore = InMemoryTokenStore();

      await pumpMobileApp(tester, tokenStore);
      await registerThroughUi(tester, email);
      await logoutThroughUi(tester);

      await loginThroughUi(tester, email);
      await expectAuthenticatedShell(tester, email);
    },
  );

  testWidgets(
    'auth smoke logout returns the mobile app to the anonymous shell',
    (tester) async {
      await withSurfaceViewport(binding, phonePrimaryIosViewport);
      final email = smokeEmail('logout');
      final tokenStore = InMemoryTokenStore();

      await pumpMobileApp(tester, tokenStore);
      await registerThroughUi(tester, email);
      await logoutThroughUi(tester);

      expect(find.text('Sign in.'), findsOneWidget);
    },
  );
}

Future<void> pumpMobileApp(WidgetTester tester, TokenStore tokenStore) async {
  await tester.pumpWidget(
    HarnessMobileApp(authGateway: AuthService(tokenStore: tokenStore)),
  );
  await tester.pumpAndSettle();
}

Future<void> registerThroughUi(WidgetTester tester, String email) async {
  await tester.ensureVisible(find.byKey(const Key('switchModeButton')));
  await tester.tap(find.byKey(const Key('switchModeButton')));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('emailField')), email);
  await tester.enterText(find.byKey(const Key('passwordField')), 'Harness1!');
  await tester.enterText(
    find.byKey(const Key('confirmPasswordField')),
    'Harness1!',
  );
  await tester.ensureVisible(find.byKey(const Key('submitButton')));
  await tester.tap(find.byKey(const Key('submitButton')));
  await waitForAuthCompletion(tester);
}

Future<void> loginThroughUi(WidgetTester tester, String email) async {
  await tester.enterText(find.byKey(const Key('emailField')), email);
  await tester.enterText(find.byKey(const Key('passwordField')), 'Harness1!');
  await tester.ensureVisible(find.byKey(const Key('submitButton')));
  await tester.tap(find.byKey(const Key('submitButton')));
  await waitForAuthCompletion(tester);
}

Future<void> logoutThroughUi(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('logoutButton')));
  await tester.tap(find.byKey(const Key('logoutButton')));
  await tester.pumpAndSettle(const Duration(seconds: 2));
  expect(find.text('Sign in.'), findsOneWidget);
}

Future<void> expectAuthenticatedShell(WidgetTester tester, String email) async {
  expect(find.text('Session restored.'), findsOneWidget);
  expect(find.text(email), findsOneWidget);
}

Future<void> waitForAuthCompletion(WidgetTester tester) async {
  for (var attempt = 0; attempt < 30; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 200));

    if (find.text('Session restored.').evaluate().isNotEmpty) {
      return;
    }

    if (find.byKey(const Key('errorBanner')).evaluate().isNotEmpty) {
      final banner = tester.widget<Text>(find.byKey(const Key('errorBanner')));
      fail('mobile auth failed: ${banner.data}');
    }
  }

  fail('mobile auth did not reach the authenticated screen');
}

String smokeEmail(String scenario) {
  return 'mobile-smoke-$scenario-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}@example.com';
}
