import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../data/auth/auth_data_source.dart';
import '../../data/auth/auth_repository_impl.dart';
import '../../data/chat/chat_data_source.dart';
import '../../data/chat/chat_repository_impl.dart';
import '../../data/users/users_data_source.dart';
import '../../data/users/users_repository_impl.dart';
import '../../domain/auth/auth_repository.dart';
import '../../domain/auth/auth_use_case.dart';
import '../../domain/chat/chat_repository.dart';
import '../../domain/chat/chat_use_case.dart';
import '../../domain/users/users_repository.dart';
import '../../domain/users/users_use_case.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/chat/bloc/chat_bloc.dart';
import '../network/network_info.dart';
import '../storage/chat_cache_storage.dart';
import '../storage/user_session_storage.dart';

/// Global service locator.
final sl = GetIt.instance;

/// Registers all app dependencies in one place.
/// Call once from [main] at app start.
Future<void> registerDependencies() async {
  // External
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => NetworkInfo());
  sl.registerLazySingleton(() => UserSessionStorage());

  final chatCache = ChatCacheStorage();
  await chatCache.init();
  sl.registerSingleton<ChatCacheStorage>(chatCache);

  // Auth module
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => AuthUseCase(sl()));
  sl.registerLazySingleton(
    () => AuthBloc(
      authUseCase: sl(),
      sessionStorage: sl(),
      chatCache: sl(),
    ),
  );

  // Users module
  sl.registerLazySingleton<UsersDataSource>(
    () => UsersDataSourceImpl(
      firestore: sl(),
      cache: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => UsersUseCase(sl()));

  // Chat module
  sl.registerLazySingleton<ChatDataSource>(
    () => ChatDataSourceImpl(
      firestore: sl(),
      cache: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => ChatUseCase(sl()));
  sl.registerLazySingleton(() => ChatBloc(chatUseCase: sl()));
}
