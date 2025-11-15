import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final AuthCubit _authCubit;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final state = _authCubit.state;
    state.maybeWhen(
      authenticated: (user) {
        setState(() {
          _currentUser = user;
        });
      },
      orElse: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentUser != null
                ? 'Chào mừng, ${_currentUser!.fullName}!'
                : 'Chào mừng, Admin!',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Quick actions
          Text('Thao tác nhanh', style: context.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.people,
                  label: 'Người dùng',
                  onTap: () => context.router.pushNamed('/users'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.book,
                  label: 'Môn học',
                  onTap: () => context.router.pushNamed('/subjects'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.quiz,
                  label: 'Câu hỏi',
                  onTap: () => context.router.pushNamed('/question-bank'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.bar_chart,
                  label: 'Thống kê',
                  onTap: () => context.router.pushNamed('/statistics'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  title: 'Người dùng',
                  value: '150',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.book,
                  title: 'Môn học',
                  value: '25',
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.assignment,
                  title: 'Đề thi',
                  value: '48',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.quiz,
                  title: 'Câu hỏi',
                  value: '1,234',
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent activities
          Text('Hoạt động gần đây', style: context.textTheme.titleLarge),
          const SizedBox(height: 16),
          _ActivityCard(
            icon: Icons.person_add,
            title: 'Người dùng mới đăng ký',
            subtitle: 'Nguyễn Văn A - Sinh viên',
            time: '5 phút trước',
          ),
          const SizedBox(height: 12),
          _ActivityCard(
            icon: Icons.assignment_turned_in,
            title: 'Bài thi mới được tạo',
            subtitle: 'Đề thi Toán học - Học kỳ 1',
            time: '1 giờ trước',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: context.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: context.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(time, style: context.textTheme.bodySmall),
      ),
    );
  }
}
