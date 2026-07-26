import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/app_user.dart';
import 'auth_repository.dart';

/// Auth module use case — single entry for all auth operations.
class AuthUseCase {
  AuthUseCase(this._repository);

  final AuthRepository _repository;

  Stream<AppUser?> watchAuthState() => _repository.watchAuthState();

  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }

  Future<Either<Failure, AppUser>> register({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _repository.register(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  Future<Either<Failure, Unit>> logout() => _repository.logout();

  Future<Either<Failure, AppUser>> getCurrentUser() {
    return _repository.getCurrentUser();
  }

  Future<Either<Failure, AppUser>> updateProfile({
    required String displayName,
    String? bio,
  }) {
    return _repository.updateProfile(
      displayName: displayName,
      bio: bio,
    );
  }

  Future<Either<Failure, Unit>> sendPasswordResetEmail({
    required String email,
  }) {
    return _repository.sendPasswordResetEmail(email: email);
  }

  Future<Either<Failure, Unit>> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) {
    return _repository.confirmPasswordReset(
      code: code,
      newPassword: newPassword,
    );
  }
}
