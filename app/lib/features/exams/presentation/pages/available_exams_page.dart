import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../data/models/exam_session_model.dart';
import '../../data/models/exam_model.dart';
import '../bloc/exam_session_cubit.dart';
import '../bloc/exam_session_state.dart';
import '../widgets/exam_card.dart';

@RoutePage()
class AvailableExamsPage extends StatefulWidget {
  const AvailableExamsPage({super.key});

  @override
  State<AvailableExamsPage> createState() => _AvailableExamsPageState();
}

class _AvailableExamsPageState extends State<AvailableExamsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ExamSessionCubit _examSessionCubit;
  List<ExamSessionModel> _allExams = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _examSessionCubit = getIt<ExamSessionCubit>();
    _loadExams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExams() async {
    await _examSessionCubit.loadMyExams();
  }

  List<ExamSessionModel> _getUpcomingExams() {
    final now = DateTime.now();
    return _allExams
        .where(
          (exam) =>
              exam.status == 'SCHEDULED' &&
              (exam.startTime.isAfter(now) ||
                  (exam.startTime.isBefore(now) && exam.endTime.isAfter(now))),
        )
        .toList();
  }

  List<ExamSessionModel> _getInProgressExams() {
    return _allExams
        .where(
          (exam) => exam.status == 'IN_PROGRESS' || exam.status == 'STARTED',
        )
        .toList();
  }

  List<ExamSessionModel> _getCompletedExams() {
    return _allExams
        .where((exam) => exam.status == 'COMPLETED' || exam.status == 'GRADED')
        .toList();
  }

  void _continueExam(ExamSessionModel examSession) {
    // Prevent starting completed exams
    if (examSession.status == 'COMPLETED' || examSession.status == 'GRADED') {
      context.showSnackBar(
        'Bài thi đã hoàn thành. Không thể làm lại.',
        isError: true,
      );
      return;
    }

    // Navigate directly to take exam page
    context.router.push(TakeExamRoute(examId: examSession.id.toString()));
  }

  void _viewResult(ExamSessionModel examSession) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết quả bài thi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              examSession.examTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildResultRow(
              'Điểm số',
              '${examSession.totalScore?.toStringAsFixed(1) ?? '0'} điểm',
            ),
            _buildResultRow(
              'Phần trăm',
              '${examSession.percentageScore?.toStringAsFixed(1) ?? '0'}%',
            ),
            _buildResultRow(
              'Kết quả',
              examSession.isPassed == true ? 'Đạt' : 'Không đạt',
              color: examSession.isPassed == true ? Colors.green : Colors.red,
            ),
            if (examSession.actualEndTime != null) ...[
              const SizedBox(height: 8),
              _buildResultRow(
                'Hoàn thành lúc',
                _formatDateTime(examSession.actualEndTime!),
              ),
            ],
            if (examSession.violationCount != null &&
                examSession.violationCount! > 0) ...[
              const SizedBox(height: 8),
              _buildResultRow(
                'Vi phạm',
                '${examSession.violationCount} lần',
                color: Colors.orange,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _examSessionCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bài thi của tôi'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Sắp diễn ra'),
              Tab(text: 'Đang làm'),
              Tab(text: 'Đã hoàn thành'),
            ],
          ),
        ),
        body: BlocConsumer<ExamSessionCubit, ExamSessionState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {},
              examsLoaded: (exams) {
                setState(() {
                  _allExams = exams;
                });
              },
              examStarted: (exam) {
                // This is handled in TakeExamPage
              },
              answerSubmitted: () {},
              examCompleted: (result) {
                context.showSnackBar(
                  'Hoàn thành bài thi! Điểm: ${result.totalScore}/${result.maxScore} (${result.percentageScore.toStringAsFixed(1)}%)',
                );
              },
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

            return TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Exams
                _buildExamList(
                  _getUpcomingExams(),
                  isLoading: isLoading,
                  type: ExamListType.upcoming,
                ),

                // In Progress Exams
                _buildExamList(
                  _getInProgressExams(),
                  isLoading: isLoading,
                  type: ExamListType.inProgress,
                ),

                // Completed Exams
                _buildExamList(
                  _getCompletedExams(),
                  isLoading: isLoading,
                  type: ExamListType.completed,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExamList(
    List<ExamSessionModel> exams, {
    required bool isLoading,
    required ExamListType type,
  }) {
    if (isLoading && _allExams.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (exams.isEmpty) {
      return EmptyState(
        icon: Icons.assignment_outlined,
        title: _getEmptyTitle(type),
        message: _getEmptyMessage(type),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExams,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final examSession = exams[index];
          final duration = examSession.endTime
              .difference(examSession.startTime)
              .inMinutes;
          // Create ExamModel from ExamSessionModel for ExamCard
          final examModel = ExamModel(
            id: examSession.examId,
            subjectId: 0, // Not available
            subjectName: '', // Not available
            title: examSession.examTitle,
            description: null,
            durationMinutes: duration,
            totalQuestions: examSession.totalQuestions ?? 0,
            totalPoints: 0.0, // Not available
            passingScore: 0.0, // Not available
            examType: 'REGULAR', // Default
            isShuffled: false,
            isShuffleAnswers: false,
            showResultImmediately: false,
            allowReview: true,
            isActive: true,
            createdAt: examSession.createdAt ?? DateTime.now(),
            createdBy: examSession.studentName,
          );
          return ExamCard(
            exam: examModel,
            onTap: () {
              // Prevent starting completed exams
              if (type == ExamListType.completed) {
                _viewResult(examSession);
                return;
              }

              if (type == ExamListType.inProgress) {
                _continueExam(examSession);
              } else {
                // Show exam details for upcoming exams
                _showExamDetails(examSession);
              }
            },
          );
        },
      ),
    );
  }

  void _showExamDetails(ExamSessionModel examSession) {
    final duration = examSession.endTime
        .difference(examSession.startTime)
        .inMinutes;
    final now = DateTime.now();
    final canStart =
        examSession.status == 'SCHEDULED' &&
        now.isAfter(examSession.startTime) &&
        now.isBefore(examSession.endTime);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(examSession.examTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (examSession.totalQuestions != null) ...[
              Text('Số câu hỏi: ${examSession.totalQuestions}'),
              const SizedBox(height: 8),
            ],
            Text('Thời gian: $duration phút'),
            const SizedBox(height: 8),
            Text('Bắt đầu: ${_formatDateTime(examSession.startTime)}'),
            const SizedBox(height: 8),
            Text('Kết thúc: ${_formatDateTime(examSession.endTime)}'),
            const SizedBox(height: 8),
            Text('Mã phiên thi: ${examSession.sessionCode}'),
            if (!canStart && now.isBefore(examSession.startTime)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bài thi chưa đến giờ bắt đầu',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!canStart && now.isAfter(examSession.endTime)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bài thi đã kết thúc',
                        style: TextStyle(color: Colors.red[800], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          if (canStart)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startExam(examSession);
              },
              child: const Text('Bắt đầu làm bài'),
            ),
        ],
      ),
    );
  }

  void _startExam(ExamSessionModel examSession) {
    // Prevent starting completed exams
    if (examSession.status == 'COMPLETED' || examSession.status == 'GRADED') {
      context.showSnackBar(
        'Bài thi đã hoàn thành. Không thể làm lại.',
        isError: true,
      );
      Navigator.pop(context); // Close the dialog
      return;
    }

    // Navigate to take exam page with session ID
    context.router.push(TakeExamRoute(examId: examSession.id.toString()));
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getEmptyTitle(ExamListType type) {
    switch (type) {
      case ExamListType.upcoming:
        return 'Chưa có bài thi nào';
      case ExamListType.inProgress:
        return 'Không có bài thi đang làm';
      case ExamListType.completed:
        return 'Chưa hoàn thành bài thi nào';
    }
  }

  String _getEmptyMessage(ExamListType type) {
    switch (type) {
      case ExamListType.upcoming:
        return 'Chưa có bài thi được lên lịch';
      case ExamListType.inProgress:
        return 'Bạn chưa bắt đầu làm bài thi nào';
      case ExamListType.completed:
        return 'Bạn chưa hoàn thành bài thi nào';
    }
  }
}

enum ExamListType { upcoming, inProgress, completed }
