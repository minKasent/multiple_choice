import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

@RoutePage()
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AuthCubit _authCubit;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    // Cache user ID on init
    _currentUserId = _authCubit.state.maybeWhen(
      authenticated: (user) => user.id,
      orElse: () => null,
    );

    // Check if user is authenticated, if not show error and go back
    if (_currentUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.showSnackBar(
            'Vui lòng đăng nhập để đổi mật khẩu',
            isError: true,
          );
          context.router.maybePop();
        }
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        context.showSnackBar('Mật khẩu mới không khớp', isError: true);
        return;
      }

      if (_currentUserId == null) {
        context.showSnackBar(
          'Không tìm thấy thông tin người dùng',
          isError: true,
        );
        return;
      }

      final data = {
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
        'confirmPassword': _confirmPasswordController.text,
      };

      await _authCubit.changePassword(_currentUserId!, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: Scaffold(
        appBar: AppBar(title: const Text('Đổi mật khẩu')),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeWhen(
              authenticated: (_) {
                // Password changed successfully
                context.showSnackBar('Đã đổi mật khẩu thành công');
                context.router.maybePop();
              },
              error: (message) {
                context.showSnackBar(message, isError: true);
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhập mật khẩu hiện tại và mật khẩu mới của bạn',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Mật khẩu hiện tại',
                      controller: _currentPasswordController,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock),
                      validator: (v) => v?.isEmpty == true
                          ? 'Vui lòng nhập mật khẩu hiện tại'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Mật khẩu mới',
                      controller: _newPasswordController,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (v) {
                        if (v?.isEmpty == true)
                          return 'Vui lòng nhập mật khẩu mới';
                        if (v!.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Xác nhận mật khẩu mới',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (v) {
                        if (v?.isEmpty == true)
                          return 'Vui lòng xác nhận mật khẩu';
                        if (v != _newPasswordController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Đổi mật khẩu',
                      onPressed: isLoading ? null : _changePassword,
                      isLoading: isLoading,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
