part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckSessionRequested extends AuthEvent {
  const AuthCheckSessionRequested();
}

class AuthLoginFormStarted extends AuthEvent {
  const AuthLoginFormStarted();
}

class AuthRememberMeChanged extends AuthEvent {
  const AuthRememberMeChanged(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}

class AuthPasswordVisibilityToggled extends AuthEvent {
  const AuthPasswordVisibilityToggled();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String email;
  final String password;
  final String displayName;

  @override
  List<Object?> get props => [email, password, displayName];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthProfileUpdated extends AuthEvent {
  const AuthProfileUpdated({
    required this.displayName,
    this.bio,
  });

  final String displayName;
  final String? bio;

  @override
  List<Object?> get props => [displayName, bio];
}

class AuthForgotPasswordRequested extends AuthEvent {
  const AuthForgotPasswordRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  const AuthResetPasswordRequested({
    required this.code,
    required this.newPassword,
  });

  final String code;
  final String newPassword;

  @override
  List<Object?> get props => [code, newPassword];
}
