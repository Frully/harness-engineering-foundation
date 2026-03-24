import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harness_mobile/main.dart';
import 'package:harness_mobile/services/auth_service.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets(
    'auth register, login, and logout work against the real backend',
    (tester) async {
      final email =
          'mobile-smoke-${DateTime.now().millisecondsSinceEpoch}@example.com';

      await tester.pumpWidget(HarnessMobileApp(authGateway: AuthService()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('switchModeButton')));
      await tester.tap(find.byKey(const Key('switchModeButton')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('emailField')), email);
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'Harness1!',
      );
      await tester.enterText(
        find.byKey(const Key('confirmPasswordField')),
        'Harness1!',
      );
      await tester.ensureVisible(find.byKey(const Key('submitButton')));
      await tester.tap(find.byKey(const Key('submitButton')));
      await waitForAuthCompletion(tester);
      expect(find.text('Mobile session restored.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('logoutButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Return to the mobile console.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('emailField')), email);
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'Harness1!',
      );
      await tester.tap(find.byKey(const Key('submitButton')));
      await waitForAuthCompletion(tester);
      expect(find.text('Mobile session restored.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('logoutButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Return to the mobile console.'), findsOneWidget);
    },
  );
}

Future<void> waitForAuthCompletion(WidgetTester tester) async {
  for (var attempt = 0; attempt < 30; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 200));

    if (find.text('Mobile session restored.').evaluate().isNotEmpty) {
      return;
    }

    if (find.byKey(const Key('errorBanner')).evaluate().isNotEmpty) {
      final banner = tester.widget<Text>(find.byKey(const Key('errorBanner')));
      fail('mobile auth failed: ${banner.data}');
    }
  }

  fail('mobile auth did not reach the authenticated screen');
}
