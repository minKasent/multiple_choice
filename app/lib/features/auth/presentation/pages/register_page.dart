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
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // Kiểm tra mật khẩu khớp
      if (_passwordController.text != _confirmPasswordController.text) {
        context.showSnackBar('Mật khẩu xác nhận không khớp', isError: true);
        return;
      }

      _authCubit.register({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
    }
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
              context.showSnackBar('Đăng ký thành công!');
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
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.router.maybePop(),
              ),
              title: const Text('Đăng ký tài khoản'),
            ),
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
                            Icons.person_add_rounded,
                            size: 80,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 24),

                          // Title
                          Text(
                            'Tạo tài khoản mới',
                            style: context.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Điền thông tin của bạn để tạo tài khoản',
                            style: context.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Username field
                          CustomTextField(
                            label: 'Tên đăng nhập',
                            hint: 'Nhập tên đăng nhập',
                            controller: _usernameController,
                            prefixIcon: const Icon(Icons.person_outlined),
                            validator: (value) =>
                                Validators.validateRequired(value, 'Tên đăng nhập'),
                          ),
                          const SizedBox(height: 16),

                          // Full name field
                          CustomTextField(
                            label: 'Họ và tên',
                            hint: 'Nhập họ và tên đầy đủ',
                            controller: _fullNameController,
                            prefixIcon: const Icon(Icons.badge_outlined),
                            validator: (value) =>
                                Validators.validateRequired(value, 'Họ và tên'),
                          ),
                          const SizedBox(height: 16),

                          // Email field
                          CustomTextField(
                            label: 'Email',
                            hint: 'Nhập email của bạn',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 16),

                          // Phone field
                          CustomTextField(
                            label: 'Số điện thoại',
                            hint: 'Nhập số điện thoại',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_outlined),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số điện thoại';
                              }
                              if (value.length < 10) {
                                return 'Số điện thoại không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          CustomTextField(
                            label: 'Mật khẩu',
                            hint: 'Nhập mật khẩu',
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outlined),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value.length < 6) {
                                return 'Mật khẩu phải có ít nhất 6 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm password field
                          CustomTextField(
                            label: 'Xác nhận mật khẩu',
                            hint: 'Nhập lại mật khẩu',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outlined),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng xác nhận mật khẩu';
                              }
                              if (value != _passwordController.text) {
                                return 'Mật khẩu không khớp';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Register button
                          CustomButton(
                            text: 'Đăng ký',
                            onPressed: _handleRegister,
                            isLoading: isLoading,
                            width: double.infinity,
                            height: 56,
                          ),
                          const SizedBox(height: 24),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đã có tài khoản? ',
                                style: context.textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: () {
                                  context.router.maybePop();
                                },
                                child: const Text('Đăng nhập ngay'),
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

