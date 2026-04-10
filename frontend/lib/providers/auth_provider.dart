import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'service_providers.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  final User? user;
  final String? token;
  final AuthStatus status;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.token,
    this.status = AuthStatus.unknown,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && token != null && user != null;
  bool get isReady => status != AuthStatus.unknown;
  bool get isRestoring => status == AuthStatus.unknown && isLoading;

  AuthState copyWith({
    Object? user = _unset,
    Object? token = _unset,
    AuthStatus? status,
    bool? isLoading,
    Object? error = _unset,
  }) {
    return AuthState(
      user: identical(user, _unset) ? this.user : user as User?,
      token: identical(token, _unset) ? this.token : token as String?,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState());

  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await ref.read(authServiceProvider).restoreSession();
      if (session == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      state = AuthState(
        user: session.user,
        token: session.token,
        status: AuthStatus.authenticated,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await ref
          .read(authServiceProvider)
          .login(username, password);
      state = AuthState(
        user: session.user,
        token: session.token,
        status: AuthStatus.authenticated,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

const _unset = Object();

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
