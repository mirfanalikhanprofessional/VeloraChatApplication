import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user_list_item.dart';
import 'users_repository.dart';

/// Users module use case.
class UsersUseCase {
  UsersUseCase(this._repository);

  final UsersRepository _repository;

  Stream<Either<Failure, List<UserListItem>>> watchUsers(String currentUserId) {
    return _repository.watchUsers(currentUserId);
  }
}
