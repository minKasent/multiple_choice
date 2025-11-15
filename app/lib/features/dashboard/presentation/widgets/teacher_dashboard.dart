import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../exams/data/models/exam_model.dart';
import '../../../exams/presentation/bloc/exams_cubit.dart';
import '../../../exams/presentation/bloc/exams_state.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  late final ExamsCubit _examsCubit;
  late final AuthCubit _authCubit;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _examsCubit = getIt<ExamsCubit>();
    _authCubit = getIt<AuthCubit>();
    _loadExams();
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
  void dispose() {
    _examsCubit.close();
    super.dispose();
  }

  Future<void> _loadExams() async {
    await _examsCubit.loadAllExams(size: 5);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _examsCubit,
      child: RefreshIndicator(
        onRefresh: _loadExams,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              _currentUser != null
                  ? 'Chào mừng, ${_currentUser!.fullName}!'
                  : 'Chào mừng, Giáo viên!',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add_circle_outline,
                    title: 'Tạo đề thi',
                    subtitle: 'Tạo đề thi mới',
                    color: AppColors.primary,
                    onTap: () =>
                        context.router.pushNamed('/exams-management/create'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.quiz_outlined,
                    title: 'Ngân hàng',
                    subtitle: 'Quản lý câu hỏi',
                    color: AppColors.secondary,
                    onTap: () => context.router.pushNamed('/question-bank'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đề thi của tôi', style: context.textTheme.titleLarge),
                TextButton(
                  onPressed: () => context.router.push(ExamsListRoute()),
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<ExamsCubit, ExamsState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  examsLoaded: (exams) => _ExamList(
                    exams: exams,
                    onExamTap: (exam) =>
                        context.router.push(ExamDetailRoute(examId: exam.id)),
                  ),
                  error: (message) => _ErrorNotice(message: message),
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
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
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 12),
              Text(
                title,
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamList extends StatelessWidget {
  final List<ExamModel> exams;
  final ValueChanged<ExamModel> onExamTap;

  const _ExamList({required this.exams, required this.onExamTap});

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return const _EmptyState();
    }

    final displayed = exams.take(4).toList();

    return Column(
      children: [
        for (final exam in displayed) ...[
          _ExamCard(exam: exam, onTap: () => onExamTap(exam)),
          if (exam != displayed.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback onTap;

  const _ExamCard({required this.exam, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = exam.isActive
        ? AppColors.statusSuccess
        : AppColors.statusPending;
    final statusLabel = exam.isActive ? 'Đã xuất bản' : 'Nháp';

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.assignment, color: AppColors.primary),
        ),
        title: Text(exam.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${exam.subjectName} • ${exam.totalQuestions} câu • ${exam.durationMinutes} phút',
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Điểm đạt: ${exam.passingScore.toStringAsFixed(1)}',
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text('Chưa có đề thi nào', style: context.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Hãy nhấn "Tạo đề thi" để bắt đầu.',
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  final String message;

  const _ErrorNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.router.push(ExamsListRoute()),
            child: const Text('Quản lý'),
          ),
        ],
      ),
    );
  }
}
