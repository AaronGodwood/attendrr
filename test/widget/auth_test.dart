import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:attendr/providers/auth_provider.dart';
import 'package:attendr/pages/login_page.dart';

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  bool isLoading = false;

  @override
  String? error;

  @override
  Future<bool> signIn({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 50));
    isLoading = false;
    notifyListeners();
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const LoginPage(),
        ),
      ),
    );
  }

  group('Authentication UI Tests (Goal 3)', () {
    testWidgets('Login Page renders correct UI elements', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Validates empty email and password', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Validates email format', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'not-an-email');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });
}