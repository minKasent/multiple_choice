import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/statistics_cubit.dart';
import '../bloc/statistics_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/chart_card.dart';

@RoutePage()
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late final StatisticsCubit _cubit;
  String _selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    _cubit = getIt<StatisticsCubit>();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    // Only load dashboard statistics for ADMIN and TEACHER
    // Students should use StudentStatisticsPage instead
    await _cubit.loadDashboardStatistics();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thống kê & Báo cáo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadStatistics,
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                context.showSnackBar('Xuất báo cáo');
              },
            ),
          ],
        ),
        body: BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: Text('Chưa có dữ liệu')),
              loading: () => const Center(child: CircularProgressIndicator()),
              dashboardStatsLoaded: (stats) => RefreshIndicator(
                onRefresh: _loadStatistics,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period selector
                      Row(
                        children: [
                          Text(
                            'Thời gian:',
                            style: context.textTheme.titleSmall,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'week',
                                  label: Text('Tuần'),
                                ),
                                ButtonSegment(
                                  value: 'month',
                                  label: Text('Tháng'),
                                ),
                                ButtonSegment(
                                  value: 'year',
                                  label: Text('Năm'),
                                ),
                              ],
                              selected: {_selectedPeriod},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _selectedPeriod = newSelection.first;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Overview stats
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.people,
                              label: 'Sinh viên',
                              value: stats.totalStudents.toString(),
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: Icons.people,
                              label: 'Giáo viên',
                              value: stats.totalTeachers.toString(),
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.assignment,
                              label: 'Đề thi',
                              value: stats.totalExams.toString(),
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: Icons.quiz,
                              label: 'Câu hỏi',
                              value: stats.totalQuestions.toString(),
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.stars,
                              label: 'Điểm TB',
                              value: stats.overallAverageScore.toStringAsFixed(1),
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: Icons.check_circle,
                              label: 'Tỷ lệ đậu',
                              value: '${stats.overallPassRate.toStringAsFixed(1)}%',
                              color: AppColors.statusSuccess,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Charts
                      Text(
                        'Biểu đồ phân tích',
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      ChartCard(
                        title: 'Phân bố điểm số',
                        chartType: 'bar',
                        data: {
                          '0-2': 2,
                          '3-4': 5,
                          '5-6': 15,
                          '7-8': 35,
                          '9-10': 13,
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      ChartCard(
                        title: 'Tỷ lệ đậu/rớt',
                        chartType: 'pie',
                        data: {
                          'Đậu': stats.overallPassRate,
                          'Rớt': 100 - stats.overallPassRate,
                        },
                      ),
                    ],
                  ),
                ),
              ),
              studentStatsLoaded: (_) => const Center(child: Text('Student stats')),
              examStatsLoaded: (_) => const Center(child: Text('Exam stats')),
              subjectStatsLoaded: (_) => const Center(child: Text('Subject stats')),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi: $message'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadStatistics,
                      child: const Text('Thử lại'),
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

