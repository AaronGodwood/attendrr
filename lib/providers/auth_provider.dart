import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailVerificationRequired,
  passwordRecovery,
}

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService.instance;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;
  StreamSubscription<AuthState>? _subscription;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = _authService.currentUser;
    _status =
        _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

    _subscription = _authService.authStateChanges.listen((state) {
      switch (state.event) {
        case AuthChangeEvent.signedIn:
          _user = state.session?.user;
          _status = AuthStatus.authenticated;
          _error = null;
          break;
        case AuthChangeEvent.signedOut:
          _user = null;
          _status = AuthStatus.unauthenticated;
          break;
        case AuthChangeEvent.passwordRecovery:
          _user = state.session?.user;
          _status = AuthStatus.passwordRecovery;
          _error = null;
          break;
        case AuthChangeEvent.userUpdated:
          _user = state.session?.user;
          break;
        default:
          break;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final result = await _authService.signUp(
      email: email,
      password: password,
      username: username,
    );

    if (result.success) {
      if (result.requiresEmailVerification) {
        _status = AuthStatus.emailVerificationRequired;
      } else {
        _user = result.user;
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final result = await _authService.signIn(email: email, password: password);

    if (result.success) {
      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final result = await _authService.signInWithGoogle();
    if (!result.success && !result.isPending) {
      _error = result.error;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _error = null;
    final result = await _authService.sendPasswordResetEmail(email);
    if (!result.success) {
      _error = result.error;
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<bool> updatePassword(String newPassword) async {
    _error = null;
    final result = await _authService.updatePassword(newPassword);
    if (!result.success) {
      _error = result.error;
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
