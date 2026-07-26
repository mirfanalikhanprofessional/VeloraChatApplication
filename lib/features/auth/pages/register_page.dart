import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/field_validation.dart';
import '../../../core/widgets/common_widgets.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with FieldValidation {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
          ),
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
          context.go(AppRoutes.home);
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
                  title: 'Create account',
                  subtitle: 'Sign up to start meaningful conversations.',
                ),
                CommonTextFormField(
                  controller: _nameController,
                  labelText: 'Display name',
                  prefixIcon: const Icon(Icons.person_outline),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: validateDisplayName,
                ),
                const VerticalSpace(16),
                CommonTextFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validateEmail,
                ),
                const VerticalSpace(16),
                CommonTextFormField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: _obscure,
                  prefixIcon: const Icon(Icons.lock_outline),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: validatePassword,
                ),
                const VerticalSpace(20),
                CommonButton.primary(
                  label: 'Sign up',
                  onPressed: _submit,
                  isLoading: loading,
                ),
                const VerticalSpace(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      child: CommonText.subtitle('Already have an account?'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: loading
                          ? null
                          : () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.login);
                              }
                            },
                      child: const CommonText(
                        'Log in',
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
