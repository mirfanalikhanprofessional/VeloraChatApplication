import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/injection_container.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/error/failures.dart' hide AuthFailure;
import '../../../core/router/app_routes.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/user_list_item.dart';
import '../../../domain/users/users_use_case.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../widgets/user_tile.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, required this.currentUser});

  final AppUser currentUser;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  int _streamKey = 0;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final value = _searchController.text.trim().toLowerCase();
      if (value != _query) setState(() => _query = value);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    setState(() => _streamKey++);
  }

  List<UserListItem> _filtered(List<UserListItem> users) {
    if (_query.isEmpty) return users;
    return users.where((item) {
      final name = item.user.displayName.toLowerCase();
      final email = item.user.email.toLowerCase();
      return name.contains(_query) || email.contains(_query);
    }).toList();
  }

  Widget _avatarFor(AppUser user, {required double radius}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.avatarPlaceholder,
      child: CommonText(
        user.initial,
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: radius * 0.65,
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push(AppRoutes.profile),
            child: _avatarFor(widget.currentUser, radius: 20),
          ),
          Expanded(
            child: Center(
              child: CommonText.headline(
                'Chats',
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarRow(List<UserListItem> users) {
    if (users.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: users.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final user = users[index].user;
          final name =
              user.displayName.isNotEmpty ? user.displayName : user.email;
          return GestureDetector(
            onTap: () => context.push(AppRoutes.chat, extra: user),
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _avatarFor(user, radius: 28),
                  const SizedBox(height: 6),
                  CommonText.caption(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsersScroll({
    required List<UserListItem> users,
    required List<UserListItem> filtered,
  }) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _retry,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(child: _buildAvatarRow(users)),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: CommonEmptyView(message: 'No matches found'),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filtered[index];
                  return UserTile(
                    item: item,
                    onTap: () {
                      context.push(AppRoutes.chat, extra: item.user);
                    },
                  );
                },
                childCount: filtered.length,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = AppBreakpoints.isExpanded(context) ? 840.0 : 720.0;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthSuccess || current is AuthFailure,
      listener: (context, state) {
        final authBloc = context.read<AuthBloc>();
        if (state is AuthSuccess && authBloc.currentUser == null) {
          context.go(AppRoutes.login);
        }
        if (state is AuthFailure && authBloc.errorMessage != null) {
          AppToast.error(context, authBloc.errorMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ResponsiveCenter(
            maxWidth: maxWidth,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildTopBar(context),
                _buildSearchBar(),
                Expanded(
                  child: StreamBuilder<Either<Failure, List<UserListItem>>>(
                    key: ValueKey(_streamKey),
                    stream: sl<UsersUseCase>()
                        .watchUsers(widget.currentUser.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const CommonLoading();
                      }

                      if (snapshot.hasError) {
                        return CommonEmptyView(
                          message: snapshot.error.toString(),
                          onRetry: _retry,
                        );
                      }

                      final result = snapshot.data;
                      if (result == null) {
                        return const CommonLoading();
                      }

                      return result.fold(
                        (failure) => CommonEmptyView(
                          message: failure.message,
                          onRetry: _retry,
                        ),
                        (users) {
                          if (users.isEmpty) {
                            return RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: _retry,
                              child: ListView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 160),
                                  CommonEmptyView(
                                    message: 'No data available',
                                  ),
                                ],
                              ),
                            );
                          }

                          return _buildUsersScroll(
                            users: users,
                            filtered: _filtered(users),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
