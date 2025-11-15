import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../data/models/chapter_model.dart';
import '../../data/models/passage_model.dart';
import '../../data/models/question_model.dart';
import '../../../exams/data/models/question_type.dart';
import '../bloc/question_bank_cubit.dart';
import '../bloc/question_bank_state.dart';

@RoutePage()
class QuestionsListPage extends StatefulWidget {
  final ChapterModel chapter;
  final PassageModel? passage;

  const QuestionsListPage({super.key, required this.chapter, this.passage});

  @override
  State<QuestionsListPage> createState() => _QuestionsListPageState();
}

class _QuestionsListPageState extends State<QuestionsListPage> {
  late final QuestionBankCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<QuestionBankCubit>();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    if (widget.passage != null) {
      await _cubit.loadQuestionsByPassage(widget.passage!.id);
    } else {
      await _cubit.loadQuestionsByChapter(widget.chapter.id);
    }
  }

  void _navigateToCreateQuestion() {
    context.router
        .push(
          CreateQuestionRoute(chapter: widget.chapter, passage: widget.passage),
        )
        .then((result) {
          if (result == true) {
            _loadQuestions();
          }
        });
  }

  void _navigateToEditQuestion(dynamic question) {
    context.router
        .push(
          CreateQuestionRoute(
            chapter: widget.chapter,
            passage: widget.passage,
            question: question,
          ),
        )
        .then((result) {
          if (result == true) {
            _loadQuestions();
          }
        });
  }

  void _deleteQuestion(dynamic question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa câu hỏi này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cubit.deleteQuestion(question.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.passage?.title ?? widget.chapter.title),
              if (widget.passage != null)
                Text(
                  widget.chapter.title,
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
        body: BlocConsumer<QuestionBankCubit, QuestionBankState>(
          listener: (context, state) {
            state.maybeWhen(
              questionDeleted: () {
                context.showSnackBar('Đã xóa câu hỏi');
                _loadQuestions();
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
              questionsLoaded: (questions) {
                if (questions.isEmpty) {
                  return EmptyState(
                    icon: Icons.quiz_outlined,
                    title: 'Chưa có câu hỏi',
                    message:
                        'Thêm câu hỏi mới cho ${widget.passage?.title ?? widget.chapter.title}',
                    actionText: 'Thêm câu hỏi',
                    onAction: _navigateToCreateQuestion,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadQuestions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return _QuestionCard(
                        question: question,
                        index: index,
                        onTap: () => _navigateToEditQuestion(question),
                        onEdit: () => _navigateToEditQuestion(question),
                        onDelete: () => _deleteQuestion(question),
                      );
                    },
                  ),
                );
              },
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi: $message'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadQuestions,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              orElse: () => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToCreateQuestion,
          icon: const Icon(Icons.add),
          label: const Text('Thêm câu hỏi'),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _QuestionCard({
    required this.question,
    required this.index,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  String _getTypeLabel() {
    return question.questionType.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final correctAnswersCount = question.answers
        .where((a) => a.isCorrect == true)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTypeLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getTypeLabel(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${question.points.toStringAsFixed(1)} điểm',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit?.call();
                      } else if (value == 'delete') {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Question content
              Text(
                question.content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Answers info
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.list, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${question.answers.length} đáp án',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '$correctAnswersCount đúng',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Explanation if exists
              if (question.explanation != null &&
                  question.explanation!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question.explanation!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
