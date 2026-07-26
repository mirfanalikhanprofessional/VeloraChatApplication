import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/field_validation.dart';
import '../../../core/widgets/common_widgets.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with FieldValidation {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthLoginFormStarted());
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthFailure ||
          current is AuthSuccess ||
          current is AuthLoginFormReady,
      buildWhen: (previous, current) =>
          current is AuthLoading ||
          current is AuthFailure ||
          current is AuthSuccess ||
          current is AuthInitial ||
          current is AuthLoginFormReady,
      listener: (context, state) {
        if (state is AuthLoginFormReady) {
          final email = context.read<AuthBloc>().rememberedEmail;
          if (email != null &&
              email.isNotEmpty &&
              _emailController.text.isEmpty) {
            _emailController.text = email;
          }
        }
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
        final authBloc = context.read<AuthBloc>();
        final loading = authBloc.isLoading;

        if (state is AuthInitial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: CommonLoading(),
          );
        }

        return AuthPageScaffold(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthPageHeader(
                  title: 'Welcome back',
                  subtitle: 'Log in to continue your conversations.',
                ),
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
                  obscureText: authBloc.obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      authBloc.obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: loading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(
                                  const AuthPasswordVisibilityToggled(),
                                );
                          },
                  ),
                  validator: (value) => validatePassword(
                    value,
                    requireMinLength: false,
                  ),
                ),
                const VerticalSpace(12),
                Row(
                  children: [
                    SizedBox(
                      height: 22,
                      width: 22,
                      child: Checkbox(
                        value: authBloc.rememberMe,
                        activeColor: AppColors.primary,
                        onChanged: loading
                            ? null
                            : (value) {
                                context.read<AuthBloc>().add(
                                      AuthRememberMeChanged(value ?? false),
                                    );
                              },
                      ),
                    ),
                    const HorizontalSpace(8),
                    GestureDetector(
                      onTap: loading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(
                                    AuthRememberMeChanged(
                                      !authBloc.rememberMe,
                                    ),
                                  );
                            },
                      child: const CommonText('Remember me'),
                    ),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: loading
                          ? null
                          : () => context.push(AppRoutes.forgotPassword),
                      child: const CommonText(
                        'Forgot password?',
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const VerticalSpace(20),
                CommonButton.primary(
                  label: 'Log in',
                  onPressed: _submit,
                  isLoading: loading,
                ),
                const VerticalSpace(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      child: CommonText.subtitle("Don't have an account?"),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: loading
                          ? null
                          : () => context.push(AppRoutes.register),
                      child: const CommonText(
                        'Sign up',
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
