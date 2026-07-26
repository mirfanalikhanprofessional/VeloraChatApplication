part of 'auth_bloc.dart';

/// Status-only. Data lives on [AuthBloc] fields.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Result of [AuthCheckSessionRequested] from splash.
class AuthSessionChecked extends AuthState {
  const AuthSessionChecked();
}

/// Login form is ready / refreshed. Field values live on [AuthBloc].
class AuthLoginFormReady extends AuthState {
  AuthLoginFormReady() : _token = Object();

  /// Ensures consecutive emits are not skipped by Equatable equality.
  final Object _token;

  @override
  List<Object?> get props => [_token];
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess();
}

class AuthFailure extends AuthState {
  const AuthFailure();
}
