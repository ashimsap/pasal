import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pasal/core/network/dio_client.dart';
import 'package:pasal/core/network/shared_preferences_provider.dart';
import 'package:pasal/domain/models/user.dart';
import 'package:pasal/domain/repositories/auth_repository.dart';

part 'auth_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref)
      : super(const AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = _ref.read(sharedPreferencesProvider).getString('token');
    if (token != null) {
      _ref.read(dioProvider).options.headers['Authorization'] = 'Bearer $token';
      try {
        final user = await _authRepository.getMe();
        state = AuthState.authenticated(user);
      } catch (e) {
        await signOut();
      }
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository, ref);
});

@freezed
class SignInState with _$SignInState {
  const factory SignInState({
    @Default(false) bool isLoading,
    @Default(AsyncValue.data(null)) AsyncValue<void> result,
  }) = _SignInState;
}

class SignInNotifier extends StateNotifier<SignInState> {
  final AuthRepository _authRepository;
  final Ref _ref;
  SignInNotifier(this._authRepository, this._ref) : super(const SignInState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, result: const AsyncValue.loading());
    try {
      await _authRepository.signIn(email, password);
      await _ref.read(authProvider.notifier).checkAuthStatus();
      state = state.copyWith(isLoading: false, result: const AsyncValue.data(null));
    } catch (e, st) {
      state = state.copyWith(isLoading: false, result: AsyncValue.error(e, st));
    }
  }
}

final signInProvider = StateNotifierProvider<SignInNotifier, SignInState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SignInNotifier(authRepository, ref);
});

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState({
    @Default(false) bool isLoading,
    @Default(AsyncValue.data(null)) AsyncValue<void> result,
  }) = _SignUpState;
}

class SignUpNotifier extends StateNotifier<SignUpState> {
  final AuthRepository _authRepository;

  SignUpNotifier(this._authRepository) : super(const SignUpState());

  Future<void> signUp(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, result: const AsyncValue.loading());
    try {
      await _authRepository.signUp(name, email, password);
      state = state.copyWith(isLoading: false, result: const AsyncValue.data(null));
    } catch (e, st) {
      state = state.copyWith(isLoading: false, result: AsyncValue.error(e, st));
    }
  }
}

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SignUpNotifier(authRepository);
});
