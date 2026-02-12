import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isLoggedIn => currentUser != null;
  String? get userId => currentUser?.id;

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      if (username.length < 3) {
        return AuthResult.failure('Username must be at least 3 characters');
      }
      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters');
      }

      // Check if username is taken
      final existing =
          await _client
              .from('profiles')
              .select('id')
              .eq('username', username)
              .maybeSingle();

      if (existing != null) {
        return AuthResult.failure('Username is already taken');
      }

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user == null) {
        return AuthResult.failure('Failed to create account');
      }

      if (response.session == null) {
        return AuthResult.success(
          user: response.user,
          message: 'Please check your email to verify your account',
          requiresEmailVerification: true,
        );
      }

      return AuthResult.success(user: response.user);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failure('Invalid credentials');
      }

      return AuthResult.success(user: response.user);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      final launchMode =
          (!kIsWeb && Platform.isIOS)
              ? LaunchMode.externalApplication
              : LaunchMode.platformDefault;
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _oauthRedirectUrl(),
        authScreenLaunchMode: launchMode,
      );
      return AuthResult.pending();
    } catch (e) {
      return AuthResult.failure('Google sign in failed');
    }
  }

  Future<AuthResult> linkGoogleIdentity() async {
    try {
      final launchMode =
          (!kIsWeb && Platform.isIOS)
              ? LaunchMode.externalApplication
              : LaunchMode.platformDefault;
      await _client.auth.linkIdentity(
        OAuthProvider.google,
        redirectTo: _oauthRedirectUrl(),
        authScreenLaunchMode: launchMode,
      );
      return AuthResult.pending();
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Google link failed');
    }
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: _passwordResetRedirectUrl(),
      );
      return AuthResult.success(message: 'Password reset email sent');
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Failed to send reset email');
    }
  }

  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return AuthResult.success(message: 'Password updated successfully');
    } catch (e) {
      return AuthResult.failure('Failed to update password');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String _oauthRedirectUrl() {
    final configured = dotenv.env['OAUTH_REDIRECT_URL']?.trim();
    if (configured != null && configured.isNotEmpty) {
      return configured;
    }
    if (kIsWeb) {
      return '${Uri.base.origin}/';
    }
    return 'com.example.attendr://login-callback';
  }

  String _passwordResetRedirectUrl() {
    final configured = dotenv.env['PASSWORD_RESET_REDIRECT_URL']?.trim();
    if (configured != null && configured.isNotEmpty) {
      return configured;
    }
    if (kIsWeb) {
      return '${Uri.base.origin}/reset-password';
    }
    return 'com.example.attendr://reset-password';
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Incorrect email or password';
    }
    if (message.contains('Email not confirmed')) {
      return 'Please verify your email before signing in';
    }
    if (message.contains('User already registered')) {
      return 'An account with this email already exists';
    }
    return message;
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final String? message;
  final String? error;
  final bool requiresEmailVerification;
  final bool isPending;

  AuthResult._({
    required this.success,
    this.user,
    this.message,
    this.error,
    this.requiresEmailVerification = false,
    this.isPending = false,
  });

  factory AuthResult.success({
    User? user,
    String? message,
    bool requiresEmailVerification = false,
  }) {
    return AuthResult._(
      success: true,
      user: user,
      message: message,
      requiresEmailVerification: requiresEmailVerification,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(success: false, error: error);
  }

  factory AuthResult.pending() {
    return AuthResult._(success: false, isPending: true);
  }
}
