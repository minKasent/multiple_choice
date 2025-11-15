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
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final AuthCubit _authCubit;
  
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    // TODO: Get current user info and populate controllers
    _authCubit.getProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = _authCubit.state.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );

      if (currentUser == null) {
        context.showSnackBar('Không tìm thấy thông tin người dùng', isError: true);
        return;
      }

      final data = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      await _authCubit.updateProfile(currentUser.id, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chỉnh sửa thông tin'),
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeWhen(
              authenticated: (user) {
                // Check if we just updated (not initial load)
                if (_fullNameController.text.isNotEmpty) {
                  context.showSnackBar('Đã cập nhật thông tin thành công');
                  context.router.maybePop(true);
                }
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

            return state.maybeWhen(
              authenticated: (user) {
                if (_fullNameController.text.isEmpty) {
                  _fullNameController.text = user.fullName;
                  _emailController.text = user.email;
                  _phoneController.text = user.phone ?? '';
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Họ và tên',
                          controller: _fullNameController,
                          prefixIcon: const Icon(Icons.person),
                          validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập họ tên' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Email',
                          controller: _emailController,
                          prefixIcon: const Icon(Icons.email),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Vui lòng nhập email';
                            if (!v!.contains('@')) return 'Email không hợp lệ';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Số điện thoại',
                          controller: _phoneController,
                          prefixIcon: const Icon(Icons.phone),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'Lưu thay đổi',
                          onPressed: isLoading ? null : _saveProfile,
                          isLoading: isLoading,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}

