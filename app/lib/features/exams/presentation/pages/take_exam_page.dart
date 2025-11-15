import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/models/exam_session_model.dart';
import '../bloc/exam_session_cubit.dart';
import '../bloc/exam_session_state.dart';
import '../widgets/answer_option.dart';
import '../widgets/question_card.dart';

@RoutePage()
class TakeExamPage extends StatefulWidget {
  final String examId;

  const TakeExamPage({super.key, @PathParam() required this.examId});

  @override
  State<TakeExamPage> createState() => _TakeExamPageState();
}

class _TakeExamPageState extends State<TakeExamPage> {
  late final ExamSessionCubit _examSessionCubit;
  int _currentQuestionIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 0;
  final Map<int, List<int>> _selectedAnswers = {}; // questionId -> answerIds

  TakeExamModel? _currentExam;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _examSessionCubit = getIt<ExamSessionCubit>();
    _startExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startExam() async {
    final sessionId = int.tryParse(widget.examId);
    if (sessionId == null) {
      context.showSnackBar('ID bài thi không hợp lệ', isError: true);
      context.router.maybePop();
      return;
    }

    await _examSessionCubit.startExam(sessionId);
  }

  void _startTimer(int durationInMinutes) {
    _remainingSeconds = durationInMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _submitExam(autoSubmit: true);
      }
    });
  }

  void _selectAnswer(int questionId, int answerId, bool isMultipleChoice) {
    // Don't allow selecting answers if time has expired
    if (_remainingSeconds <= 0) {
      return;
    }

    setState(() {
      if (isMultipleChoice) {
        // Multiple choice: toggle answer
        if (_selectedAnswers.containsKey(questionId)) {
          if (_selectedAnswers[questionId]!.contains(answerId)) {
            _selectedAnswers[questionId]!.remove(answerId);
          } else {
            _selectedAnswers[questionId]!.add(answerId);
          }
        } else {
          _selectedAnswers[questionId] = [answerId];
        }
      } else {
        // Single choice: replace answer
        _selectedAnswers[questionId] = [answerId];
      }
    });

    // Auto-submit answer to backend
    _submitAnswerToBackend(questionId);
  }

  Future<void> _submitAnswerToBackend(int questionId) async {
    final sessionId = int.tryParse(widget.examId);
    if (sessionId == null || !_selectedAnswers.containsKey(questionId)) return;

    // Don't submit if time has expired
    if (_remainingSeconds <= 0) {
      return;
    }

    try {
      await _examSessionCubit.submitAnswer(
        sessionId,
        questionId,
        _selectedAnswers[questionId]!,
      );
    } catch (e) {
      // Silently handle "Exam time has expired" errors
      // The exam will be auto-completed by backend
      if (e.toString().contains('Exam time has expired') ||
          e.toString().contains('Exam is not in progress')) {
        // Time expired, exam will be auto-completed
        return;
      }
      // Re-throw other errors
      rethrow;
    }
  }

  void _nextQuestion() {
    if (_currentExam == null) return;
    if (_currentQuestionIndex < _currentExam!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _jumpToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
    });
    Navigator.pop(context);
  }

  void _showQuestionNavigator() {
    if (_currentExam == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách câu hỏi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_currentExam!.questions.length, (index) {
                final question = _currentExam!.questions[index];
                final isAnswered =
                    _selectedAnswers.containsKey(question.id) &&
                    _selectedAnswers[question.id]!.isNotEmpty;
                final isCurrent = index == _currentQuestionIndex;

                return GestureDetector(
                  onTap: () => _jumpToQuestion(index),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : isAnswered
                          ? Colors.green
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrent || isAnswered
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildLegend(AppColors.primary, 'Hiện tại'),
                const SizedBox(width: 16),
                _buildLegend(Colors.green, 'Đã trả lời'),
                const SizedBox(width: 16),
                _buildLegend(Colors.grey[300]!, 'Chưa trả lời'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _submitExam({bool autoSubmit = false}) async {
    if (_isSubmitting) return;

    // Count unanswered questions
    final unanswered = _currentExam!.questions.length - _selectedAnswers.length;

    if (!autoSubmit && unanswered > 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận nộp bài'),
          content: Text(
            'Bạn còn $unanswered câu chưa trả lời.\nBạn có chắc chắn muốn nộp bài?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Nộp bài'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final sessionId = int.tryParse(widget.examId);
    if (sessionId != null) {
      await _examSessionCubit.completeExam(sessionId);
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _examSessionCubit,
      child: BlocConsumer<ExamSessionCubit, ExamSessionState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            examsLoaded: (exams) {},
            examStarted: (exam) {
              // Check if exam time has expired using remainingTime from backend
              if (exam.remainingTime != null && exam.remainingTime! <= 0) {
                // Time expired, show message and go back
                context.showSnackBar('Đã hết hạn làm bài thi', isError: true);
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    context.router.maybePop();
                  }
                });
                return;
              }

              setState(() {
                _currentExam = exam;
              });

              // Use remainingTime from backend if available, otherwise calculate
              if (exam.remainingTime != null && exam.remainingTime! > 0) {
                _remainingSeconds = exam.remainingTime!;
                _startTimer((_remainingSeconds / 60).ceil());
              } else {
                // Fallback: calculate remaining time
                final now = DateTime.now();
                final endTime = exam.endTime;
                final remaining = endTime.difference(now).inSeconds;

                if (remaining > 0) {
                  _remainingSeconds = remaining;
                  _startTimer((remaining / 60).ceil());
                } else {
                  // Time already expired
                  _remainingSeconds = 0;
                  _submitExam(autoSubmit: true);
                }
              }
            },
            answerSubmitted: () {
              // Answer saved successfully
            },
            examCompleted: (result) {
              _timer?.cancel();
              // Show result dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('Hoàn thành bài thi'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Điểm số: ${result.totalScore.toStringAsFixed(1)}/${result.maxScore.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đúng: ${result.correctAnswers}/${result.totalQuestions}',
                      ),
                      Text(
                        'Tỷ lệ: ${result.percentageScore.toStringAsFixed(1)}%',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.isPassed ? 'Đạt' : 'Không đạt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: result.isPassed ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.router.maybePop();
                      },
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              );
            },
            error: (message) {
              setState(() {
                _isSubmitting = false;
              });

              // Handle specific error messages
              if (message.contains('Exam time has expired') ||
                  message.contains('Đã hết hạn')) {
                context.showSnackBar('Đã hết hạn làm bài thi', isError: true);
                // Auto-complete exam if time expired
                final sessionId = int.tryParse(widget.examId);
                if (sessionId != null && _currentExam != null) {
                  Future.delayed(const Duration(seconds: 1), () {
                    _submitExam(autoSubmit: true);
                  });
                }
              } else if (message.contains('Exam already completed') ||
                  message.contains('đã hoàn thành')) {
                // Exam already completed, navigate back
                context.showSnackBar(
                  'Bài thi đã hoàn thành. Không thể làm lại.',
                  isError: true,
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  context.router.maybePop();
                });
              } else {
                context.showSnackBar(message, isError: true);
              }
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          if (isLoading && _currentExam == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Đang tải bài thi...')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (_currentExam == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Lỗi')),
              body: const Center(child: Text('Không thể tải bài thi')),
            );
          }

          final currentQuestion =
              _currentExam!.questions[_currentQuestionIndex];
          final isMultipleChoice = currentQuestion.type == 'MULTIPLE_CHOICE';

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, dynamic result) async {
              if (didPop) return;

              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Thoát bài thi?'),
                  content: const Text(
                    'Bạn có chắc chắn muốn thoát? Tiến trình của bạn đã được lưu.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Ở lại'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Thoát'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(_currentExam!.examTitle),
                actions: [
                  // Timer
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _remainingSeconds < 300
                            ? Colors.red
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(_remainingSeconds),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Question navigator
                  IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: _showQuestionNavigator,
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value:
                        (_currentQuestionIndex + 1) /
                        _currentExam!.questions.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),

                  // Question counter
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Câu ${_currentQuestionIndex + 1}/${_currentExam!.questions.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Đã trả lời: ${_selectedAnswers.length}/${_currentExam!.questions.length}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Question content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Passage (if exists)
                          if (currentQuestion.passage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentQuestion.passage!.content,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Question
                          QuestionCard(
                            questionNumber: _currentQuestionIndex + 1,
                            content: currentQuestion.content,
                            type: currentQuestion.type,
                          ),
                          const SizedBox(height: 16),

                          // Answers
                          ...currentQuestion.answers.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final answer = entry.value;
                            final isSelected =
                                _selectedAnswers[currentQuestion.id]?.contains(
                                  answer.id,
                                ) ??
                                false;

                            return AnswerOption(
                              index: index,
                              content: answer.content,
                              isSelected: isSelected,
                              onTap: () => _selectAnswer(
                                currentQuestion.id,
                                answer.id,
                                isMultipleChoice,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (_currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousQuestion,
                              child: const Text('Câu trước'),
                            ),
                          ),
                        if (_currentQuestionIndex > 0)
                          const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child:
                              _currentQuestionIndex <
                                  _currentExam!.questions.length - 1
                              ? ElevatedButton(
                                  onPressed: _nextQuestion,
                                  child: const Text('Câu tiếp theo'),
                                )
                              : ElevatedButton(
                                  onPressed: () => _submitExam(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Nộp bài'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
