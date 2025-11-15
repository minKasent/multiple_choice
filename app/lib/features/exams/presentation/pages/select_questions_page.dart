import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../question_bank/data/models/chapter_model.dart';
import '../../../question_bank/data/models/question_model.dart';
import '../../../question_bank/presentation/bloc/question_bank_cubit.dart';
import '../../../question_bank/presentation/bloc/question_bank_state.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/question_type.dart';
import '../bloc/exams_cubit.dart';
import '../bloc/exams_state.dart';

@RoutePage()
class SelectQuestionsPage extends StatefulWidget {
  final int examId;
  final int? subjectId;

  const SelectQuestionsPage({super.key, required this.examId, this.subjectId});

  @override
  State<SelectQuestionsPage> createState() => _SelectQuestionsPageState();
}

class _SelectQuestionsPageState extends State<SelectQuestionsPage> {
  late final ExamsCubit _examsCubit;
  late final QuestionBankCubit _questionBankCubit;

  final Map<int, _SelectedQuestion> _selectedQuestions = {};
  List<ChapterModel> _chapters = [];
  ChapterModel? _selectedChapter;
  List<QuestionModel> _questions = [];

  @override
  void initState() {
    super.initState();
    _examsCubit = getIt<ExamsCubit>();
    _questionBankCubit = getIt<QuestionBankCubit>();

    // Load exam detail to get subject
    _examsCubit.loadExamDetail(widget.examId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadQuestionsForChapter(ChapterModel chapter) {
    setState(() {
      _selectedChapter = chapter;
    });
    _questionBankCubit.loadQuestionsByChapter(chapter.id);
  }

  void _toggleQuestion(QuestionModel question) {
    setState(() {
      if (_selectedQuestions.containsKey(question.id)) {
        _selectedQuestions.remove(question.id);
      } else {
        _selectedQuestions[question.id] = _SelectedQuestion(
          question: question,
          points: question.points,
          displayOrder: _selectedQuestions.length + 1,
        );
      }
    });
  }

  void _updatePoints(int questionId, double points) {
    setState(() {
      if (_selectedQuestions.containsKey(questionId)) {
        _selectedQuestions[questionId] = _selectedQuestions[questionId]!
            .copyWith(points: points);
      }
    });
  }

  Future<void> _showSelectedQuestionsDialog() async {
    if (_selectedQuestions.isEmpty) {
      context.showSnackBar('Vui lòng chọn ít nhất 1 câu hỏi', isError: true);
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Câu hỏi đã chọn (${_selectedQuestions.length})'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _selectedQuestions.length,
              itemBuilder: (context, index) {
                final entry = _selectedQuestions.entries.elementAt(index);
                final selected = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(
                      selected.question.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      children: [
                        Text('Điểm: '),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.all(8),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                              text: selected.points.toString(),
                            ),
                            onChanged: (value) {
                              final points = double.tryParse(value);
                              if (points != null && points > 0) {
                                _updatePoints(entry.key, points);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedQuestions.remove(entry.key);
                        });
                        setDialogState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitQuestions();
              },
              child: const Text('Hoàn thành'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuestions() async {
    final items = _selectedQuestions.entries
        .map(
          (e) => ExamQuestionItem(
            questionId: e.key,
            displayOrder: e.value.displayOrder,
            points: e.value.points,
          ),
        )
        .toList();

    final request = AddQuestionsRequest(questions: items);
    await _examsCubit.addQuestionsToExam(widget.examId, request);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _examsCubit),
        BlocProvider.value(value: _questionBankCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ExamsCubit, ExamsState>(
            listener: (context, state) {
              state.maybeWhen(
                examDetailLoaded: (exam) {
                  // Load chapters for this subject
                  _questionBankCubit.loadChaptersBySubject(exam.subjectId);
                },
                questionsAdded: (exam) {
                  context.showSnackBar(
                    'Đã thêm ${_selectedQuestions.length} câu hỏi vào đề thi',
                  );
                  context.router.maybePop(true);
                },
                error: (message) {
                  context.showSnackBar(message, isError: true);
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<QuestionBankCubit, QuestionBankState>(
            listener: (context, state) {
              state.maybeWhen(
                chaptersLoaded: (chapters) {
                  setState(() {
                    _chapters = chapters;
                    if (chapters.isNotEmpty) {
                      _loadQuestionsForChapter(chapters.first);
                    }
                  });
                },
                questionsLoaded: (questions) {
                  setState(() {
                    _questions = questions;
                  });
                },
                orElse: () {},
              );
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Chọn câu hỏi'),
            actions: [
              if (_selectedQuestions.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Đã chọn: ${_selectedQuestions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: BlocBuilder<QuestionBankCubit, QuestionBankState>(
            builder: (context, state) {
              final isLoading = state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );

              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Chapter selector
                  if (_chapters.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<ChapterModel>(
                        value: _selectedChapter,
                        decoration: const InputDecoration(
                          labelText: 'Chọn chương',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.folder_outlined),
                        ),
                        items: _chapters
                            .map(
                              (chapter) => DropdownMenuItem(
                                value: chapter,
                                child: Text(chapter.title),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _loadQuestionsForChapter(value);
                          }
                        },
                      ),
                    ),

                  // Questions list
                  Expanded(
                    child: _questions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.quiz_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa có câu hỏi trong chương này',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _questions.length,
                            itemBuilder: (context, index) {
                              final question = _questions[index];
                              final isSelected = _selectedQuestions.containsKey(
                                question.id,
                              );

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: isSelected
                                    ? Colors.blue.shade50
                                    : Colors.white,
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (_) => _toggleQuestion(question),
                                  title: Text(
                                    question.content,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Wrap(
                                      spacing: 12,
                                      children: [
                                        Chip(
                                          label: Text(
                                            question.questionType.displayName,
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        Chip(
                                          label: Text(
                                            '${question.points.toStringAsFixed(1)} điểm',
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                          backgroundColor: Colors.blue.shade100,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ],
                                    ),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedQuestions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng: ${_selectedQuestions.length} câu',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_selectedQuestions.values.fold<double>(0, (sum, q) => sum + q.points).toStringAsFixed(1)} điểm',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectedQuestions.isEmpty
                              ? null
                              : _showSelectedQuestionsDialog,
                          icon: const Icon(Icons.visibility),
                          label: const Text('Xem đã chọn'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          text: 'Hoàn thành',
                          onPressed: _selectedQuestions.isEmpty
                              ? null
                              : _submitQuestions,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedQuestion {
  final QuestionModel question;
  final double points;
  final int displayOrder;

  _SelectedQuestion({
    required this.question,
    required this.points,
    required this.displayOrder,
  });

  _SelectedQuestion copyWith({
    QuestionModel? question,
    double? points,
    int? displayOrder,
  }) {
    return _SelectedQuestion(
      question: question ?? this.question,
      points: points ?? this.points,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
