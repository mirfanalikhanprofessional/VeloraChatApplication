import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> watchAuthState();

  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, AppUser>> getCurrentUser();

  Future<Either<Failure, AppUser>> updateProfile({
    required String displayName,
    String? bio,
  });

  Future<Either<Failure, Unit>> sendPasswordResetEmail({
    required String email,
  });

  Future<Either<Failure, Unit>> confirmPasswordReset({
    required String code,
    required String newPassword,
  });
}
