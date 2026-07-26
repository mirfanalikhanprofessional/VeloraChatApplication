import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/chat/bloc/chat_bloc.dart';
import 'injection_container.dart';

/// All app Bloc providers.
final List<BlocProvider> appProviders = [
  BlocProvider<AuthBloc>(
    create: (_) => sl<AuthBloc>(),
  ),
  BlocProvider<ChatBloc>(
    create: (_) => sl<ChatBloc>(),
  ),
];
