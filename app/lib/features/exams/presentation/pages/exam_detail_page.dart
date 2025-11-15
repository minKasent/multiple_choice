import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/models/exam_model.dart';
import '../bloc/exams_cubit.dart';
import '../bloc/exams_state.dart';

@RoutePage()
class ExamDetailPage extends StatefulWidget {
  final int examId;

  const ExamDetailPage({super.key, required this.examId});

  @override
  State<ExamDetailPage> createState() => _ExamDetailPageState();
}

class _ExamDetailPageState extends State<ExamDetailPage> {
  late final ExamsCubit _cubit;
  ExamDetailModel? _exam;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ExamsCubit>();
    _cubit.loadExamDetail(widget.examId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showDeleteQuestionDialog(ExamQuestionModel question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa câu hỏi này khỏi đề thi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cubit.removeQuestionFromExam(widget.examId, question.questionId);
    }
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'MULTIPLE_CHOICE':
        return 'Nhiều lựa chọn';
      case 'TRUE_FALSE':
        return 'Đúng/Sai';
      case 'FILL_IN_BLANK':
        return 'Điền khuyết';
      default:
        return type;
    }
  }

  String _getDifficultyLabel(String level) {
    switch (level) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      default:
        return level;
    }
  }

  Color _getDifficultyColor(String level) {
    switch (level) {
      case 'EASY':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HARD':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  ExamModel? _mapExamDetailToExamModel() {
    final exam = _exam;
    if (exam == null) {
      return null;
    }
    return ExamModel(
      id: exam.id,
      subjectId: exam.subjectId,
      subjectName: exam.subjectName,
      title: exam.title,
      description: exam.description,
      durationMinutes: exam.durationMinutes,
      totalQuestions: exam.totalQuestions,
      totalPoints: exam.totalPoints,
      passingScore: exam.passingScore,
      examType: exam.examType,
      isShuffled: exam.isShuffled,
      isShuffleAnswers: exam.isShuffleAnswers,
      showResultImmediately: exam.showResultImmediately,
      allowReview: exam.allowReview,
      isActive: exam.isActive,
      createdAt: exam.createdAt,
      createdBy: exam.createdBy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết đề thi'),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Chỉnh sửa'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'add_questions',
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('Thêm câu hỏi'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'shuffle',
                  child: Row(
                    children: [
                      Icon(Icons.shuffle),
                      SizedBox(width: 8),
                      Text('Xáo trộn'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'schedule',
                  child: Row(
                    children: [
                      Icon(Icons.event_available),
                      SizedBox(width: 8),
                      Text('Lên lịch thi'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clone',
                  child: Row(
                    children: [
                      Icon(Icons.content_copy),
                      SizedBox(width: 8),
                      Text('Nhân bản'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    final examModel = _mapExamDetailToExamModel();
                    if (examModel != null) {
                      await context.router.push(
                        CreateExamRoute(exam: examModel),
                      );
                    }
                    break;
                  case 'add_questions':
                    context.router.push(
                      SelectQuestionsRoute(examId: widget.examId),
                    );
                    break;
                  case 'shuffle':
                    _cubit.shuffleExam(widget.examId);
                    break;
                  case 'schedule':
                    final examModel = _mapExamDetailToExamModel();
                    if (examModel != null) {
                      final isScheduled = await context.router.push<bool>(
                        ScheduleExamRoute(exam: examModel),
                      );
                      if (isScheduled == true && mounted) {
                        context.showSnackBar(
                          'Đã lên lịch đề thi cho sinh viên',
                        );
                      }
                    }
                    break;
                  case 'clone':
                    _cubit.cloneExam(widget.examId);
                    break;
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<ExamsCubit, ExamsState>(
          listener: (context, state) {
            state.maybeWhen(
              questionRemoved: () {
                context.showSnackBar('Đã xóa câu hỏi khỏi đề thi');
                _cubit.loadExamDetail(widget.examId);
              },
              examShuffled: (exam) {
                context.showSnackBar('Đã xáo trộn đề thi');
                _cubit.loadExamDetail(widget.examId);
              },
              examCloned: (exam) {
                context.showSnackBar('Đã nhân bản đề thi thành công');
                context.router.maybePop();
              },
              error: (message) {
                context.showSnackBar(message, isError: true);
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              examDetailLoaded: (exam) {
                _exam = exam;

                return RefreshIndicator(
                  onRefresh: () async {
                    _cubit.loadExamDetail(widget.examId);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Exam info card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exam.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                exam.subjectName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (exam.description != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  exam.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  _buildInfoChip(
                                    Icons.timer_outlined,
                                    '${exam.durationMinutes} phút',
                                  ),
                                  _buildInfoChip(
                                    Icons.quiz_outlined,
                                    '${exam.totalQuestions} câu',
                                  ),
                                  _buildInfoChip(
                                    Icons.grade_outlined,
                                    '${exam.totalPoints.toStringAsFixed(1)} điểm',
                                  ),
                                  _buildInfoChip(
                                    Icons.check_circle_outline,
                                    'Điểm đạt: ${exam.passingScore.toStringAsFixed(1)}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    exam.createdBy,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(exam.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Questions list
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Danh sách câu hỏi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              context.router.push(
                                SelectQuestionsRoute(examId: widget.examId),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (exam.questions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.quiz_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa có câu hỏi nào',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...exam.questions.map((question) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                child: Text('${question.displayOrder}'),
                              ),
                              title: Text(
                                question.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Chip(
                                      label: Text(
                                        _getQuestionTypeLabel(
                                          question.questionType,
                                        ),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    Chip(
                                      label: Text(
                                        _getDifficultyLabel(
                                          question.difficultyLevel ?? '',
                                        ),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      backgroundColor: _getDifficultyColor(
                                        question.difficultyLevel ?? '',
                                      ).withValues(alpha: 0.2),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    Chip(
                                      label: Text(
                                        '${question.points} điểm',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _showDeleteQuestionDialog(question),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Đáp án:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...question.answers.map((answer) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                child: Text(
                                                  '${answer.displayOrder}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(answer.content),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      if (question.explanation != null) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Row(
                                                children: [
                                                  Icon(
                                                    Icons.lightbulb_outline,
                                                    size: 16,
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Giải thích:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(question.explanation!),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }
}
