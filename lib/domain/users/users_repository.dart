import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user_list_item.dart';

abstract class UsersRepository {
  Stream<Either<Failure, List<UserListItem>>> watchUsers(String currentUserId);
}
