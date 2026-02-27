import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:attendr/repositories/user_repository.dart';
import 'package:attendr/models/user.dart' as app_models;

late String testUserEmail;
late String testUserPassword;
late String nonExistentId;
final bool _envFileExists = File('.env.test').existsSync();
bool _envReady = _envFileExists;

void main() {
  late SupabaseClient client;
  final userRepository = UserRepository.instance;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    if (!_envFileExists) {
      _envReady = false;
      return;
    }

    final envFile = File('.env.test');
    await dotenv.load(fileName: envFile.absolute.path);

    if (dotenv.env['TEST_USER_EMAIL'] == null ||
        dotenv.env['TEST_USER_PASSWORD'] == null ||
        dotenv.env['SUPABASE_URL'] == null ||
        dotenv.env['SUPABASE_ANON_KEY'] == null) {
      _envReady = false;
      return;
    }

    testUserEmail = dotenv.env['TEST_USER_EMAIL']!;
    testUserPassword = dotenv.env['TEST_USER_PASSWORD']!;
    nonExistentId = dotenv.env['NON_EXISTENT_ID'] ?? 'non-existent-id';

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    client = Supabase.instance.client;
  });

  setUp(() async {
    if (!_envReady) return; // setUp; not a test — silent skip is correct here.
    if (client.auth.currentSession != null) {
      await client.auth.signOut();
    }
  });

  // Data Integrity
  group('Data Integrity Tests (Model Parsing)', () {
    test('User Model correctly parses profile data', () async {
      if (!_envReady) {
        markTestSkipped('Skipped: no .env.test file with required credentials');
        return;
      }
      await client.auth.signInWithPassword(
        email: testUserEmail,
        password: testUserPassword,
      );

      final user = await userRepository.getCurrentUser();

      expect(
        user,
        isA<app_models.User>(),
        reason: "Should return a valid User object",
      );
    });
  });

  // Security (RLS)
  group('RLS Policy Access Tests (NFR4 - Security)', () {
    test('RLS: Unauthenticated user cannot read profiles', () async {
      if (!_envReady) {
        markTestSkipped('Skipped: no .env.test file with required credentials');
        return;
      }
      expect(() => userRepository.getCurrentUser(), throwsA(isA<Exception>()));
    });

    test('RLS: Authenticated user CAN read OWN profile data', () async {
      if (!_envReady) {
        markTestSkipped('Skipped: no .env.test file with required credentials');
        return;
      }
      await client.auth.signInWithPassword(
        email: testUserEmail,
        password: testUserPassword,
      );

      expect(() => userRepository.getCurrentUser(), returnsNormally);
    });
  });
}
