import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_menu_item.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _authCubit.getProfile();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _authCubit.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
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
            authenticated: (user) {},
            unauthenticated: () {
              // Clear toàn bộ navigation stack và về login
              context.router.replaceAll([const LoginRoute()]);
            },
            error: (message) {
              context.showSnackBar(message, isError: true);
            },
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            authenticated: (user) => Scaffold(
              appBar: AppBar(
                title: const Text('Thông tin cá nhân'),
              ),
              body: LoadingOverlay(
                isLoading: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Avatar & Basic Info
                      ProfileInfoCard(user: user),
                      const SizedBox(height: 24),

                      // Menu Items
                      ProfileMenuItem(
                        icon: Icons.person_outline,
                        title: 'Chỉnh sửa thông tin',
                        onTap: () {
                          context.router.pushNamed('/profile/edit');
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.lock_outline,
                        title: 'Đổi mật khẩu',
                        onTap: () {
                          context.router.pushNamed('/profile/change-password');
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Cài đặt',
                        onTap: () {
                          // TODO: Navigate to settings
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.help_outline,
                        title: 'Trợ giúp',
                        onTap: () {
                          // TODO: Navigate to help
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.info_outline,
                        title: 'Về ứng dụng',
                        onTap: () {
                          // TODO: Show about dialog
                        },
                      ),
                      const SizedBox(height: 24),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(
                            Icons.logout,
                            color: AppColors.error,
                          ),
                          label: const Text(
                            'Đăng xuất',
                            style: TextStyle(color: AppColors.error),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Version
                      Text(
                        'Version 1.0.0',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            unauthenticated: () => const Scaffold(),
            error: (message) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(message),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _authCubit.getProfile(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

