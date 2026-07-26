import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/field_validation.dart';
import '../../../core/widgets/common_widgets.dart';
import '../bloc/auth_bloc.dart';

/// Completes Firebase password reset using the code from the email link.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with FieldValidation {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          AuthResetPasswordRequested(
            code: _codeController.text.trim(),
            newPassword: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.email.isEmpty
        ? 'Open the reset email and copy the reset code from the link URL, '
            'then choose a new password.'
        : 'We sent a reset link to ${widget.email}. Open it, copy the reset '
            'code from the URL, then choose a new password.';

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthFailure || current is AuthSuccess,
      buildWhen: (previous, current) =>
          current is AuthLoading ||
          current is AuthFailure ||
          current is AuthSuccess ||
          current is AuthInitial,
      listener: (context, state) {
        if (state is AuthFailure) {
          final message = context.read<AuthBloc>().errorMessage;
          if (message != null) {
            AppToast.error(context, message);
          }
        }
        if (state is AuthSuccess) {
          AppToast.success(context, 'Password updated. Please log in.');
          context.go(AppRoutes.login);
        }
      },
      builder: (context, state) {
        final loading = context.read<AuthBloc>().isLoading;
        return AuthPageScaffold(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthPageHeader(
                  title: 'Reset password',
                  subtitle: subtitle,
                ),
                CommonTextFormField(
                  controller: _codeController,
                  labelText: 'Reset code',
                  prefixIcon: const Icon(Icons.link_outlined),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  validator: (value) => validateRequired(
                    value,
                    fieldName: 'Reset code',
                  ),
                ),
                const VerticalSpace(16),
                CommonTextFormField(
                  controller: _passwordController,
                  labelText: 'New password',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: validatePassword,
                ),
                const VerticalSpace(16),
                CommonTextFormField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm password',
                  obscureText: _obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outline),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                  validator: _validateConfirmPassword,
                ),
                const VerticalSpace(20),
                CommonButton.primary(
                  label: 'Update password',
                  onPressed: _submit,
                  isLoading: loading,
                ),
                const VerticalSpace(16),
                TextButton(
                  onPressed: loading
                      ? null
                      : () => context.go(AppRoutes.login),
                  child: const CommonText(
                    'Back to log in',
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
