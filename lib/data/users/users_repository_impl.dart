import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user_list_item.dart';
import '../../domain/users/users_repository.dart';
import 'users_data_source.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl({required this.dataSource});

  final UsersDataSource dataSource;

  @override
  Stream<Either<Failure, List<UserListItem>>> watchUsers(
    String currentUserId,
  ) async* {
    try {
      await for (final users in dataSource.watchUsers(currentUserId)) {
        yield Right(users);
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      yield Left(NetworkFailure(e.message));
    } catch (_) {
      yield const Left(UnexpectedFailure('Failed to load users'));
    }
  }
}
