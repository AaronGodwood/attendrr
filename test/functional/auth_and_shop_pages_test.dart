import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:attendr/pages/forgot_password_page.dart';
import 'package:attendr/pages/reset_password_page.dart';
import 'package:attendr/pages/signup_page.dart';
import 'package:attendr/pages/splash_page.dart';
import 'package:attendr/providers/auth_provider.dart';
import 'package:attendr/providers/profile_provider.dart';

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  bool isLoading = false;
  @override
  String? error;
  @override
  AuthStatus status = AuthStatus.unauthenticated;

  bool resetCalled = false;
  bool signUpCalled = false;
  String? lastSignUpEmail;
  String? lastSignUpUsername;

  @override
  Future<bool> sendPasswordResetEmail(String email) async {
    resetCalled = true;
    return true;
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    signUpCalled = true;
    lastSignUpEmail = email;
    lastSignUpUsername = username;
    return false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockProfileProvider extends ChangeNotifier implements ProfileProvider {
  int refreshCount = 0;

  @override
  Future<void> refresh() async {
    refreshCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Forgot password sends reset and shows success state', (
    tester,
  ) async {
    final auth = MockAuthProvider();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: const ForgotPasswordPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    expect(auth.resetCalled, isTrue);
    expect(find.text('Check Your Email'), findsOneWidget);
  });

  testWidgets('Reset password validates required fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: MockAuthProvider(),
          child: const ResetPasswordPage(),
        ),
      ),
    );

    await tester.tap(find.text('Update Password'));
    await tester.pump();
    expect(find.text('Please enter a password'), findsOneWidget);

    expect(find.text('Reset Password'), findsOneWidget);
  });

  testWidgets('Signup validations render and trigger submit path', (
    tester,
  ) async {
    final auth = MockAuthProvider();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: const SignUpPage(),
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();
    expect(find.text('Please enter a username'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'valid_user',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'StrongPass1!',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm Password'),
      'StrongPass1!',
    );
    final createAccountButton = find.widgetWithText(
      ElevatedButton,
      'Create Account',
    );
    await tester.ensureVisible(createAccountButton);
    final submitButton = tester.widget<ElevatedButton>(createAccountButton);
    expect(submitButton.onPressed, isNotNull);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    expect(auth.signUpCalled, isTrue);
    expect(auth.lastSignUpEmail, 'user@example.com');
    expect(auth.lastSignUpUsername, 'valid_user');
  });

  testWidgets('Splash page renders brand and spinner', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));
    expect(find.text('Attendr'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
