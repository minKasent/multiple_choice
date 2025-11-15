import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/models/statistics_model.dart';
import '../bloc/statistics_cubit.dart';
import '../bloc/statistics_state.dart';
import '../widgets/stats_card.dart';

@RoutePage()
class StatisticsDashboardPage extends StatefulWidget {
  const StatisticsDashboardPage({super.key});

  @override
  State<StatisticsDashboardPage> createState() =>
      _StatisticsDashboardPageState();
}

class _StatisticsDashboardPageState extends State<StatisticsDashboardPage> {
  late final StatisticsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<StatisticsCubit>();
    _cubit.loadDashboardStatistics();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thống kê tổng quan'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _cubit.loadDashboardStatistics(),
            ),
          ],
        ),
        body: BlocConsumer<StatisticsCubit, StatisticsState>(
          listener: (context, state) {
            state.maybeWhen(
              error: (message) {
                context.showSnackBar(message, isError: true);
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              dashboardStatsLoaded: (stats) => _buildDashboard(stats),
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(DashboardStatsModel stats) {
    return RefreshIndicator(
      onRefresh: () async => _cubit.loadDashboardStatistics(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Statistics
            const Text(
              'Người dùng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Tổng người dùng',
                    value: stats.totalUsers.toString(),
                    icon: Icons.people_outline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Học sinh',
                    value: stats.totalStudents.toString(),
                    icon: Icons.school_outlined,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Giáo viên',
                    value: stats.totalTeachers.toString(),
                    icon: Icons.person_outline,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Container()),
              ],
            ),
            const SizedBox(height: 24),

            // Content Statistics
            const Text(
              'Nội dung',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Môn học',
                    value: stats.totalSubjects.toString(),
                    icon: Icons.book_outlined,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Câu hỏi',
                    value: stats.totalQuestions.toString(),
                    icon: Icons.quiz_outlined,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Đề thi',
                    value: stats.totalExams.toString(),
                    icon: Icons.assignment_outlined,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Container()),
              ],
            ),
            const SizedBox(height: 24),

            // Exam Sessions Statistics
            const Text(
              'Bài thi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Tổng bài thi',
                    value: stats.totalSessions.toString(),
                    icon: Icons.article_outlined,
                    color: Colors.cyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Đã hoàn thành',
                    value: stats.completedSessions.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Performance Statistics
            const Text(
              'Kết quả học tập',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPerformanceRow(
                      'Điểm trung bình:',
                      '${stats.overallAverageScore.toStringAsFixed(2)}/10',
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildPerformanceRow(
                      'Tỷ lệ đạt:',
                      '${(stats.overallPassRate * 100).toStringAsFixed(1)}%',
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats Summary
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Tóm tắt',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hệ thống hiện có ${stats.totalUsers} người dùng, '
                      'bao gồm ${stats.totalStudents} học sinh và ${stats.totalTeachers} giáo viên. '
                      'Với ${stats.totalSubjects} môn học, ${stats.totalQuestions} câu hỏi, '
                      'và ${stats.totalExams} đề thi.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đã có ${stats.completedSessions} bài thi hoàn thành '
                      'trong tổng số ${stats.totalSessions} bài thi, '
                      'với điểm trung bình là ${stats.overallAverageScore.toStringAsFixed(2)}/10 '
                      'và tỷ lệ đạt ${(stats.overallPassRate * 100).toStringAsFixed(1)}%.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

