import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/field_validation.dart';
import '../../../core/widgets/common_widgets.dart';
import '../bloc/auth_bloc.dart';

/// Sends Firebase's free password-reset email.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with FieldValidation {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _emailFocus.unfocus();
    context.read<AuthBloc>().add(
          AuthForgotPasswordRequested(email: _emailController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
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
          AppToast.success(
            context,
            'Reset email sent. Check your inbox for the link.',
          );
          context.push(
            AppRoutes.resetPassword,
            extra: _emailController.text.trim(),
          );
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
                const AuthPageHeader(
                  title: 'Forgot password?',
                  subtitle:
                      "Enter the email linked to your account and we'll send "
                      'a reset link. Open the email, copy the reset code from '
                      'the link, then set a new password.',
                ),
                CommonTextFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofocus: true,
                  onFieldSubmitted: (_) => _submit(),
                  validator: validateEmail,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                ),
                const VerticalSpace(20),
                CommonButton.primary(
                  label: 'Send reset email',
                  onPressed: _submit,
                  isLoading: loading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
