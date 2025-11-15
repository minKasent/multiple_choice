import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../data/models/chapter_model.dart';
import '../../data/models/passage_model.dart';
import '../../data/models/question_model.dart';
import '../../../exams/data/models/question_type.dart';
import '../bloc/question_bank_cubit.dart';
import '../bloc/question_bank_state.dart';

@RoutePage()
class CreateQuestionPage extends StatefulWidget {
  final ChapterModel chapter;
  final PassageModel? passage;
  final QuestionModel? question; // For editing

  const CreateQuestionPage({
    super.key,
    required this.chapter,
    this.passage,
    this.question,
  });

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  late final QuestionBankCubit _cubit;

  final _contentController = TextEditingController();
  final _explanationController = TextEditingController();
  final _pointsController = TextEditingController(text: '1.0');

  QuestionType _questionType = QuestionType.multipleChoice;

  final List<_AnswerItem> _answers = [];

  @override
  void initState() {
    super.initState();
    _cubit = getIt<QuestionBankCubit>();

    if (widget.question != null) {
      // Edit mode
      _contentController.text = widget.question!.content;
      _explanationController.text = widget.question!.explanation ?? '';
      _pointsController.text = widget.question!.points.toString();
      _questionType = widget.question!.questionType;

      for (var answer in widget.question!.answers) {
        _answers.add(
          _AnswerItem(
            controller: TextEditingController(text: answer.content),
            isCorrect: answer.isCorrect,
            displayOrder: answer.displayOrder ?? _answers.length + 1,
          ),
        );
      }
    } else {
      // Create mode - add 2 empty answers
      _addAnswer();
      _addAnswer();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _explanationController.dispose();
    _pointsController.dispose();
    for (var answer in _answers) {
      answer.controller.dispose();
    }
    super.dispose();
  }

  void _addAnswer() {
    setState(() {
      _answers.add(
        _AnswerItem(
          controller: TextEditingController(),
          isCorrect: false,
          displayOrder: _answers.length + 1,
        ),
      );
    });
  }

  void _removeAnswer(int index) {
    if (_answers.length > 2) {
      setState(() {
        _answers[index].controller.dispose();
        _answers.removeAt(index);
        // Update display order
        for (int i = 0; i < _answers.length; i++) {
          _answers[i].displayOrder = i + 1;
        }
      });
    } else {
      context.showSnackBar('Phải có ít nhất 2 đáp án', isError: true);
    }
  }

  void _toggleCorrect(int index) {
    setState(() {
      if (_questionType == QuestionType.multipleChoice) {
        // Multiple choice: can have multiple correct answers
        _answers[index].isCorrect = !_answers[index].isCorrect;
      } else {
        // Single choice: only one correct answer
        for (int i = 0; i < _answers.length; i++) {
          _answers[i].isCorrect = (i == index);
        }
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate at least one correct answer
    final hasCorrect = _answers.any((a) => a.isCorrect);
    if (!hasCorrect) {
      context.showSnackBar('Phải có ít nhất 1 đáp án đúng', isError: true);
      return;
    }

    // Validate all answers have content
    for (var answer in _answers) {
      if (answer.controller.text.trim().isEmpty) {
        context.showSnackBar('Tất cả đáp án phải có nội dung', isError: true);
        return;
      }
    }

    final passageId = widget.passage?.id;
    final chapterId = widget.chapter.id;

    final requestData = {
      if (passageId != null) 'passageId': passageId,
      if (passageId == null) 'chapterId': chapterId,
      'content': _contentController.text.trim(),
      'questionType': const QuestionTypeConverter().toJson(_questionType),
      'points': double.tryParse(_pointsController.text) ?? 1.0,
      'displayOrder': 1,
      if (_explanationController.text.trim().isNotEmpty)
        'explanation': _explanationController.text.trim(),
      'answers': _answers
          .asMap()
          .entries
          .map(
            (entry) => {
              'content': entry.value.controller.text.trim(),
              'isCorrect': entry.value.isCorrect,
              'displayOrder': entry.key + 1,
            },
          )
          .toList(),
    };

    if (widget.question != null) {
      // Update
      await _cubit.updateQuestion(widget.question!.id, requestData);
    } else {
      // Create
      await _cubit.createQuestion(requestData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<QuestionBankCubit, QuestionBankState>(
        listener: (context, state) {
          state.maybeWhen(
            questionCreated: (_) {
              context.showSnackBar('Tạo câu hỏi thành công');
              context.router.maybePop(true);
            },
            questionUpdated: (_) {
              context.showSnackBar('Cập nhật câu hỏi thành công');
              context.router.maybePop(true);
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

          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.question != null
                    ? 'Chỉnh sửa câu hỏi'
                    : 'Tạo câu hỏi mới',
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Chapter info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chương: ${widget.chapter.title}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (widget.passage != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Đoạn văn: ${widget.passage!.title}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Question content
                  CustomTextField(
                    controller: _contentController,
                    label: 'Nội dung câu hỏi',
                    hint: 'Nhập nội dung câu hỏi...',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập nội dung câu hỏi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Question type
                  DropdownButtonFormField<QuestionType>(
                    value: _questionType,
                    decoration: const InputDecoration(
                      labelText: 'Loại câu hỏi',
                      border: OutlineInputBorder(),
                    ),
                    items: QuestionType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _questionType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Points
                  CustomTextField(
                    controller: _pointsController,
                    label: 'Điểm',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập điểm';
                      }
                      final points = double.tryParse(value);
                      if (points == null || points <= 0) {
                        return 'Điểm phải lớn hơn 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Explanation
                  CustomTextField(
                    controller: _explanationController,
                    label: 'Giải thích (tùy chọn)',
                    hint: 'Giải thích đáp án đúng...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Answers section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Đáp án',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addAnswer,
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm đáp án'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Answers list
                  ..._answers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final answer = entry.value;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Correct checkbox
                            Checkbox(
                              value: answer.isCorrect,
                              onChanged: (_) => _toggleCorrect(index),
                            ),
                            // Answer content
                            Expanded(
                              child: TextField(
                                controller: answer.controller,
                                decoration: InputDecoration(
                                  labelText: 'Đáp án ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeAnswer(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                  Text(
                    'Chú ý: Đánh dấu ô checkbox để chọn đáp án đúng',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  CustomButton(
                    text: widget.question != null ? 'Cập nhật' : 'Tạo câu hỏi',
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
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

class _AnswerItem {
  final TextEditingController controller;
  bool isCorrect;
  int displayOrder;

  _AnswerItem({
    required this.controller,
    required this.isCorrect,
    required this.displayOrder,
  });
}
