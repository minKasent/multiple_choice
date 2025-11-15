import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../exams/data/models/exam_session_model.dart';
import '../../../exams/presentation/bloc/exam_session_cubit.dart';
import '../../../exams/presentation/bloc/exam_session_state.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late final ExamSessionCubit _examSessionCubit;
  late final AuthCubit _authCubit;
  List<ExamSessionModel> _sessions = [];
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _examSessionCubit = getIt<ExamSessionCubit>();
    _authCubit = getIt<AuthCubit>();
    _loadSessions();
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
    _examSessionCubit.close();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    await _examSessionCubit.loadMyExams();
  }

  List<ExamSessionModel> get _upcomingSessions {
    final now = DateTime.now();
    final upcoming = _sessions
        .where(
          (session) =>
              session.status == 'SCHEDULED' &&
              (session.startTime.isAfter(now) ||
                  (session.startTime.isBefore(now) &&
                      session.endTime.isAfter(now))),
        )
        .toList();
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.take(3).toList();
  }

  List<ExamSessionModel> get _recentResults {
    final finished = _sessions.where((session) {
      return session.status == 'COMPLETED' ||
          session.status == 'GRADED' ||
          session.totalScore != null;
    }).toList();
    finished.sort((a, b) {
      final aTime = a.actualEndTime ?? a.endTime;
      final bTime = b.actualEndTime ?? b.endTime;
      return bTime.compareTo(aTime);
    });
    return finished.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _examSessionCubit,
      child: RefreshIndicator(
        onRefresh: _loadSessions,
        color: AppColors.primary,
        child: BlocConsumer<ExamSessionCubit, ExamSessionState>(
          listener: (context, state) {
            state.maybeWhen(
              examsLoaded: (sessions) {
                setState(() {
                  _sessions = sessions;
                });
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

            return ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(
                  _currentUser != null
                      ? 'Chào mừng, ${_currentUser!.fullName}!'
                      : 'Chào mừng, Sinh viên!',
                  style: context.textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Bài thi sắp diễn ra',
                  actionLabel: 'Xem tất cả',
                  onActionPressed: () =>
                      context.router.push(AvailableExamsRoute()),
                ),
                const SizedBox(height: 12),
                if (isLoading && _sessions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_upcomingSessions.isEmpty)
                  const _EmptyStudentState(
                    icon: Icons.event_available,
                    title: 'Chưa có bài thi nào sắp diễn ra',
                    message:
                        'Khi giáo viên lên lịch, bài thi sẽ xuất hiện ở đây.',
                  )
                else
                  ..._upcomingSessions.map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _UpcomingExamCard(
                        session: session,
                        onTap: () => context.router.push(AvailableExamsRoute()),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                Text('Kết quả gần đây', style: context.textTheme.titleLarge),
                const SizedBox(height: 12),
                if (isLoading && _sessions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_recentResults.isEmpty)
                  const _EmptyStudentState(
                    icon: Icons.insights_outlined,
                    title: 'Chưa có kết quả nào',
                    message: 'Hoàn thành bài thi để xem điểm của bạn.',
                  )
                else
                  ..._recentResults.map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ResultCard(session: session),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionPressed;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: context.textTheme.titleLarge),
        TextButton(onPressed: onActionPressed, child: Text(actionLabel)),
      ],
    );
  }
}

class _UpcomingExamCard extends StatelessWidget {
  final ExamSessionModel session;
  final VoidCallback onTap;

  const _UpcomingExamCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(session.startTime);
    final time = _formatTime(session.startTime);
    final duration = session.endTime.difference(session.startTime).inMinutes;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.assignment,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.examTitle,
                          style: context.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (session.totalQuestions != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${session.totalQuestions} câu hỏi',
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoChip(icon: Icons.calendar_today, label: date),
                  _InfoChip(
                    icon: Icons.access_time,
                    label: '$time ($duration phút)',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final twoDigits = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.hour}:$twoDigits';
  }
}

class _ResultCard extends StatelessWidget {
  final ExamSessionModel session;

  const _ResultCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final score = session.totalScore ?? 0;
    final percentage = session.percentageScore?.toDouble() ?? 0;
    final color = percentage >= 80
        ? AppColors.statusSuccess
        : percentage >= 50
        ? AppColors.warning
        : AppColors.error;
    final completedAt = session.actualEndTime ?? session.endTime;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Text(
            score.toStringAsFixed(1),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          session.examTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${_formatDate(completedAt)} • $percentage%'),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: context.textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyStudentState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyStudentState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            title,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
