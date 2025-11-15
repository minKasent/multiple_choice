import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _authCubit.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _handleGoogleSignIn() {
    _authCubit.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            authenticated: (user) {
              // Clear toàn bộ navigation stack và chỉ giữ dashboard
              context.router.replaceAll([const DashboardRoute()]);
            },
            unauthenticated: () {},
            error: (message) {
              context.showSnackBar(message, isError: true);
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Scaffold(
            body: LoadingOverlay(
              isLoading: isLoading,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          Icon(
                            Icons.school_rounded,
                            size: 80,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 24),

                          // Title
                          Text(
                            'Đăng nhập',
                            style: context.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chào mừng trở lại! Vui lòng đăng nhập để tiếp tục',
                            style: context.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Email field
                          CustomTextField(
                            label: 'Email',
                            hint: 'Nhập email của bạn',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          CustomTextField(
                            label: 'Mật khẩu',
                            hint: 'Nhập mật khẩu của bạn',
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outlined),
                            validator: (value) =>
                                Validators.validateRequired(value, 'Mật khẩu'),
                          ),
                          const SizedBox(height: 12),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password
                              },
                              child: const Text('Quên mật khẩu?'),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login button
                          CustomButton(
                            text: 'Đăng nhập',
                            onPressed: _handleLogin,
                            isLoading: isLoading,
                            width: double.infinity,
                            height: 56,
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Hoặc',
                                  style: context.textTheme.bodySmall,
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Google Sign In button
                          CustomButton(
                            text: 'Đăng nhập bằng Google',
                            onPressed: _handleGoogleSignIn,
                            type: ButtonType.outlined,
                            icon: Image.asset(
                              'assets/images/google_logo.png',
                              height: 24,
                              width: 24,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.login,
                                size: 24,
                              ),
                            ),
                            width: double.infinity,
                            height: 56,
                          ),
                          const SizedBox(height: 32),

                          // Register link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Chưa có tài khoản? ',
                                style: context.textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: () {
                                  context.router.pushNamed('/register');
                                },
                                child: const Text('Đăng ký ngay'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

