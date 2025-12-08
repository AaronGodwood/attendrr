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

void main() {
  late SupabaseClient client;
  final userRepository = UserRepository.instance;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    final envFile = File('.env.test');

    if (!envFile.existsSync()) {
      print("CRITICAL ERROR: .env.test not found.");
      print("Looking in: ${envFile.absolute.path}");
      print("Current Working Directory: ${Directory.current.path}");
      throw Exception("Could not find .env.test file. Please ensure it exists in the project root.");
    }

    await dotenv.load(fileName: envFile.absolute.path);

    if (dotenv.env['TEST_USER_EMAIL'] == null) {
      throw Exception('TEST_USER_EMAIL not found in .env.test');
    }
    testUserEmail = dotenv.env['TEST_USER_EMAIL']!;

    if (dotenv.env['TEST_USER_PASSWORD'] == null) {
      throw Exception('TEST_USER_PASSWORD not found in .env.test');
    }
    testUserPassword = dotenv.env['TEST_USER_PASSWORD']!;

    nonExistentId = dotenv.env['NON_EXISTENT_ID'] ?? 'non-existent-id';

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    client = Supabase.instance.client;
  });

  setUp(() async {
    if (client.auth.currentSession != null) {
      await client.auth.signOut();
    }
  });

  // Data Integrity
  group('Data Integrity Tests (Model Parsing)', () {
    test('User Model correctly parses profile data', () async {
      await client.auth.signInWithPassword(
        email: testUserEmail,
        password: testUserPassword,
      );

      final user = await userRepository.getCurrentUser();

      expect(user, isA<app_models.User>(), reason: "Should return a valid User object");
    });
  });

  // Security (RLS)
  group('RLS Policy Access Tests (NFR4 - Security)', () {

    test('RLS: Unauthenticated user cannot read profiles', () async {
      expect(
            () => userRepository.getCurrentUser(),
        throwsA(isA<Exception>()),
      );
    });

    test('RLS: Authenticated user CAN read OWN profile data', () async {
      await client.auth.signInWithPassword(
        email: testUserEmail,
        password: testUserPassword,
      );

      expect(
            () => userRepository.getCurrentUser(),
        returnsNormally,
      );
    });

  });
}