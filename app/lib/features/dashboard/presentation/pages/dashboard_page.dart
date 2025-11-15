import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/admin_dashboard.dart';
import '../widgets/student_dashboard.dart';
import '../widgets/teacher_dashboard.dart';

@RoutePage()
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final AuthCubit _authCubit;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _authCubit.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return state.when(
            initial: () => const _LoadingScreen(),
            loading: () => const _LoadingScreen(),
            authenticated: (user) => _buildDashboard(user.role.name),
            unauthenticated: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Clear toàn bộ navigation stack khi logout
                context.router.replaceAll([const LoginRoute()]);
              });
              return const _LoadingScreen();
            },
            error: (message) => _buildErrorScreen(message),
          );
        },
      ),
    );
  }

  Widget _buildDashboard(String role) {
    Widget body;

    switch (role) {
      case AppConstants.roleAdmin:
        body = const AdminDashboard();
        break;
      case AppConstants.roleTeacher:
        body = const TeacherDashboard();
        break;
      case AppConstants.roleStudent:
        body = const StudentDashboard();
        break;
      default:
        body = const Center(child: Text('Role không hợp lệ'));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Tắt nút back
        title: const Text('Hệ thống thi trắc nghiệm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              context.router.pushNamed('/profile');
            },
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: _buildBottomNav(role),
    );
  }

  Widget? _buildBottomNav(String role) {
    List<BottomNavigationBarItem> items = [];

    switch (role) {
      case AppConstants.roleAdmin:
        items = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Người dùng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Môn học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ];
        break;
      case AppConstants.roleTeacher:
        items = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Môn học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Đề thi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ];
        break;
      case AppConstants.roleStudent:
        items = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Bài thi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ];
        break;
    }

    if (items.isEmpty) return null;

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        _handleNavigation(index, role);
      },
      items: items,
    );
  }

  void _handleNavigation(int index, String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        switch (index) {
          case 0:
            // Dashboard - already here
            break;
          case 1:
            // Users
            context.router.pushNamed('/users');
            break;
          case 2:
            // Subjects
            context.router.pushNamed('/subjects');
            break;
          case 3:
            // Profile
            context.router.pushNamed('/profile');
            break;
        }
        break;
      case AppConstants.roleTeacher:
        switch (index) {
          case 0:
            // Dashboard
            break;
          case 1:
            // Subjects
            context.router.pushNamed('/subjects');
            break;
          case 2:
            // Exams management
            context.router.pushNamed('/exams-management');
            break;
          case 3:
            // Profile
            context.router.pushNamed('/profile');
            break;
        }
        break;
      case AppConstants.roleStudent:
        switch (index) {
          case 0:
            // Dashboard
            break;
          case 1:
            // Exams
            context.router.pushNamed('/exams');
            break;
          case 2:
            // History - Navigate to student statistics page
            context.router.pushNamed('/statistics/student');
            break;
          case 3:
            // Profile
            context.router.pushNamed('/profile');
            break;
        }
        break;
    }
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Đã xảy ra lỗi', style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _authCubit.logout();
              },
              child: const Text('Đăng nhập lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
