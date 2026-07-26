import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/chat_cache_storage.dart';
import '../../../core/storage/user_session_storage.dart';
import '../../../domain/auth/auth_use_case.dart';
import '../../../domain/entities/app_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Auth module Bloc — session check + auth actions.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthUseCase authUseCase,
    required UserSessionStorage sessionStorage,
    required ChatCacheStorage chatCache,
  })  : _authUseCase = authUseCase,
        _sessionStorage = sessionStorage,
        _chatCache = chatCache,
        super(const AuthInitial()) {
    on<AuthCheckSessionRequested>(_onCheckSession);
    on<AuthLoginFormStarted>(_onLoginFormStarted);
    on<AuthRememberMeChanged>(_onRememberMeChanged);
    on<AuthPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthProfileUpdated>(_onProfileUpdated);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthResetPasswordRequested>(_onResetPassword);
  }

  final AuthUseCase _authUseCase;
  final UserSessionStorage _sessionStorage;
  final ChatCacheStorage _chatCache;

  AppUser? currentUser;
  bool isLoading = false;
  String? errorMessage;
  String? statusMessage;

  String? rememberedEmail;
  bool rememberMe = false;
  bool obscurePassword = true;

  bool get isLoggedIn => currentUser != null;

  Future<bool> get hasSeenWelcome => _sessionStorage.hasSeenWelcome();

  Future<void> markWelcomeSeen() => _sessionStorage.markWelcomeSeen();

  Future<void> _onCheckSession(
    AuthCheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    errorMessage = null;
    statusMessage = null;

    final rememberMeEnabled = await _sessionStorage.isRememberMeEnabled();
    if (rememberMeEnabled) {
      final cached = await _sessionStorage.readSession();
      if (cached != null) {
        currentUser = cached;
        emit(const AuthSessionChecked());
        return;
      }
    } else {
      await _sessionStorage.clearSession();
    }

    final result = await _authUseCase.getCurrentUser();
    await result.fold(
      (_) async {
        currentUser = null;
        emit(const AuthSessionChecked());
      },
      (user) async {
        // Firebase may still have a persisted auth user. Only keep them signed
        // in across launches when Remember me was enabled.
        if (rememberMeEnabled) {
          currentUser = user;
          await _sessionStorage.saveSession(user);
          emit(const AuthSessionChecked());
          return;
        }

        await _authUseCase.logout();
        currentUser = null;
        await _sessionStorage.clearSession();
        emit(const AuthSessionChecked());
      },
    );
  }

  Future<void> _onLoginFormStarted(
    AuthLoginFormStarted event,
    Emitter<AuthState> emit,
  ) async {
    rememberMe = await _sessionStorage.isRememberMeEnabled();
    rememberedEmail = await _sessionStorage.getRememberedEmail();
    obscurePassword = true;
    emit(AuthLoginFormReady());
  }

  void _onRememberMeChanged(
    AuthRememberMeChanged event,
    Emitter<AuthState> emit,
  ) {
    rememberMe = event.value;
    emit(AuthLoginFormReady());
  }

  void _onPasswordVisibilityToggled(
    AuthPasswordVisibilityToggled event,
    Emitter<AuthState> emit,
  ) {
    obscurePassword = !obscurePassword;
    emit(AuthLoginFormReady());
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    errorMessage = null;
    statusMessage = null;
    isLoading = true;
    emit(const AuthLoading());
    final result = await _authUseCase.login(
      email: event.email,
      password: event.password,
    );
    isLoading = false;
    await result.fold(
      (failure) async {
        errorMessage = failure.message;
        emit(const AuthFailure());
        emit(AuthLoginFormReady());
      },
      (user) async {
        currentUser = user;
        await _sessionStorage.saveRememberMe(
          rememberMe: rememberMe,
          email: event.email,
        );
        if (rememberMe) {
          await _sessionStorage.saveSession(user);
        } else {
          await _sessionStorage.clearSession();
        }
        emit(const AuthSuccess());
      },
    );
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    errorMessage = null;
    statusMessage = null;
    isLoading = true;
    emit(const AuthLoading());
    final result = await _authUseCase.register(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );
    isLoading = false;
    await result.fold(
      (failure) async {
        errorMessage = failure.message;
        emit(const AuthFailure());
      },
      (user) async {
        currentUser = user;
        await _sessionStorage.saveRememberMe(
          rememberMe: false,
          email: event.email,
        );
        emit(const AuthSuccess());
      },
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    errorMessage = null;
    isLoading = true;
    emit(const AuthLoading());
    final result = await _authUseCase.logout();
    isLoading = false;
    await result.fold(
      (failure) async {
        errorMessage = failure.message;
        emit(const AuthFailure());
      },
      (_) async {
        currentUser = null;
        rememberMe = false;
        rememberedEmail = null;
        obscurePassword = true;
        await _sessionStorage.clearAll();
        await _chatCache.clearAll();
        statusMessage = 'Logged out';
        emit(const AuthSuccess());
      },
    );
  }

  Future<void> _onProfileUpdated(
    AuthProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    errorMessage = null;
    statusMessage = null;
    isLoading = true;
    emit(const AuthLoading());
    final result = await _authUseCase.updateProfile(
      displayName: event.displayName,
      bio: event.bio,
    );
    isLoading = false;
    await result.fold(
      (failure) async {
        errorMessage = failure.message;
        emit(const AuthFailure());
      },
      (user) async {
        currentUser = user;
        if (await _sessionStorage.isRememberMeEnabled()) {
          await _sessionStorage.saveSession(user);
        }
        statusMessage = 'Profile updated';
        emit(const AuthSuccess());
      },
    );
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    errorMessage = null;
    statusMessage = null;
    isLoading = true;
    emit(const AuthLoading());
    final result =
        await _authUseCase.sendPasswordResetEmail(email: event.email);
    isLoading = false;
    result.fold(
      (failure) {
        errorMessage = failure.message;
        emit(const AuthFailure());
      },
      (_) {
        statusMessage = 'Password reset email sent';
        emit(const AuthSuccess());
      },
    );
  }

  Future<void> _onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    errorMessage = null;
    statusMessage = null;
    isLoading = true;
    emit(const AuthLoading());
    final result = await _authUseCase.confirmPasswordReset(
      code: event.code,
      newPassword: event.newPassword,
    );
    isLoading = false;
    result.fold(
      (failure) {
        errorMessage = failure.message;
        emit(const AuthFailure());
      },
      (_) {
        statusMessage = 'Password updated. Please log in.';
        emit(const AuthSuccess());
      },
    );
  }
}
