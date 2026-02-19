import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:attendr/pages/settings_page.dart';
import 'package:attendr/providers/auth_provider.dart';
import 'package:attendr/providers/profile_provider.dart';
import 'package:attendr/providers/theme_provider.dart';
import 'package:attendr/models/user.dart' as app_models;

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  MockAuthProvider({
    this.user,
    this.linkSucceeds = true,
    this.deleteSucceeds = true,
  });

  @override
  supabase.User? user;

  @override
  String? error;

  bool linkCalled = false;
  bool deleteCalled = false;
  final bool linkSucceeds;
  final bool deleteSucceeds;

  @override
  Future<bool> linkGoogleIdentity() async {
    linkCalled = true;
    return linkSucceeds;
  }

  @override
  Future<bool> deleteAccount() async {
    deleteCalled = true;
    return deleteSucceeds;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockProfileProvider extends ChangeNotifier implements ProfileProvider {
  MockProfileProvider(this._user);

  final app_models.User _user;

  @override
  app_models.User? get user => _user;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  app_models.User buildUser() {
    final now = DateTime(2025, 1, 1);
    return app_models.User(
      id: 'user-1',
      email: 'test@example.com',
      username: 'tester',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pumpSettings(
    WidgetTester tester, {
    required MockAuthProvider auth,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<ProfileProvider>.value(
            value: MockProfileProvider(buildUser()),
          ),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('IT-Settings: link Google calls provider', (tester) async {
    final auth = MockAuthProvider(user: null);
    await pumpSettings(tester, auth: auth);

    await tester.tap(find.text('Link Google Account'));
    await tester.pumpAndSettle();

    expect(auth.linkCalled, isTrue);
  });

  testWidgets('IT-Settings: delete account confirm calls provider', (
    tester,
  ) async {
    final auth = MockAuthProvider(user: null, deleteSucceeds: false);
    await pumpSettings(tester, auth: auth);

    await tester.scrollUntilVisible(
      find.text('Delete Account'),
      300,
      scrollable: find.byType(Scrollable),
    );

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(auth.deleteCalled, isTrue);
  });
}
