import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/field_validation.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../domain/entities/app_user.dart';
import '../bloc/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});

  final AppUser user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with FieldValidation {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _resetControllers(AppUser user) {
    _nameController.text = user.displayName;
    _bioController.text = user.bio ?? '';
  }

  void _toggleEdit(AppUser user) {
    setState(() {
      if (_isEditing) {
        _resetControllers(user);
      }
      _isEditing = !_isEditing;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthProfileUpdated(
            displayName: _nameController.text.trim(),
            bio: _bioController.text.trim(),
          ),
        );
  }

  Widget _labeledValue({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const HorizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.caption(label),
                const SizedBox(height: 2),
                CommonText(
                  value.isNotEmpty ? value : 'Not set',
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        title: const CommonText(
          'Profile',
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                current is AuthLoading ||
                current is AuthSuccess ||
                current is AuthFailure,
            builder: (context, state) {
              final authBloc = context.read<AuthBloc>();
              final user = authBloc.currentUser ?? widget.user;
              return TextButton(
                onPressed: authBloc.isLoading ? null : () => _toggleEdit(user),
                child: CommonText(
                  _isEditing ? 'Cancel' : 'Edit',
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current is AuthFailure || current is AuthSuccess,
        buildWhen: (previous, current) =>
            current is AuthLoading ||
            current is AuthFailure ||
            current is AuthSuccess ||
            current is AuthInitial ||
            current is AuthSessionChecked,
        listener: (context, state) {
          final authBloc = context.read<AuthBloc>();
          if (state is AuthSuccess) {
            if (authBloc.currentUser == null) {
              context.go(AppRoutes.login);
              return;
            }
            if (authBloc.statusMessage != null) {
              AppToast.success(context, authBloc.statusMessage!);
              setState(() => _isEditing = false);
            }
          }
          if (state is AuthFailure) {
            final message = authBloc.errorMessage;
            if (message != null) {
              AppToast.error(context, message);
            }
          }
        },
        builder: (context, state) {
          final authBloc = context.read<AuthBloc>();
          final loading = authBloc.isLoading;
          final user = authBloc.currentUser ?? widget.user;
          final bio = user.bio?.isNotEmpty == true
              ? user.bio!
              : "Hey there! I'm using Velora.";

          return Form(
            key: _formKey,
            child: ResponsiveCenter(
              maxWidth: 520,
              padding: EdgeInsets.zero,
              child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.avatarPlaceholder,
                    child: CommonText(
                      user.initial,
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const VerticalSpace(20),
                if (!_isEditing) ...[
                  CommonText(
                    user.displayName.isNotEmpty
                        ? user.displayName
                        : user.email,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                  ),
                  const VerticalSpace(6),
                  CommonText.subtitle(
                    bio,
                    textAlign: TextAlign.center,
                  ),
                  const VerticalSpace(28),
                  _labeledValue(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                ] else ...[
                  CommonTextFormField(
                    controller: _nameController,
                    labelText: 'Display name',
                    validator: validateDisplayName,
                  ),
                  const VerticalSpace(16),
                  CommonTextFormField(
                    controller: _bioController,
                    labelText: 'Bio',
                    maxLines: 3,
                  ),
                  const VerticalSpace(16),
                  CommonTextFormField(
                    initialValue: user.email,
                    labelText: 'Email',
                    enabled: false,
                  ),
                  const VerticalSpace(24),
                  CommonButton.primary(
                    label: 'Save changes',
                    onPressed: _save,
                    isLoading: loading,
                  ),
                ],
                const VerticalSpace(32),
                CommonButton(
                  label: 'Sign out',
                  backgroundColor: AppColors.signOutBackground,
                  foregroundColor: AppColors.error,
                  onPressed: loading
                      ? null
                      : () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthLogoutRequested());
                        },
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}
