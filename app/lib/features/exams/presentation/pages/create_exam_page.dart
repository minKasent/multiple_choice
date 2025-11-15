import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../subjects/data/models/subject_model.dart';
import '../../../subjects/presentation/bloc/subjects_cubit.dart';
import '../../../subjects/presentation/bloc/subjects_state.dart';
import '../../data/models/exam_model.dart';
import '../bloc/exams_cubit.dart';
import '../bloc/exams_state.dart';

@RoutePage()
class CreateExamPage extends StatefulWidget {
  final ExamModel? exam; // For editing
  final int? subjectId; // For creating with pre-selected subject

  const CreateExamPage({super.key, this.exam, this.subjectId});

  @override
  State<CreateExamPage> createState() => _CreateExamPageState();
}

class _CreateExamPageState extends State<CreateExamPage> {
  final _formKey = GlobalKey<FormState>();
  late final ExamsCubit _examsCubit;
  late final SubjectsCubit _subjectsCubit;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '60');
  final _passingScoreController = TextEditingController(text: '5.0');

  SubjectModel? _selectedSubject;
  String _examType = 'REGULAR';
  bool _isShuffled = true;
  bool _isShuffleAnswers = true;
  bool _showResultImmediately = false;
  bool _allowReview = true;

  List<SubjectModel> _subjects = [];

  @override
  void initState() {
    super.initState();
    _examsCubit = getIt<ExamsCubit>();
    _subjectsCubit = getIt<SubjectsCubit>();

    if (widget.exam != null) {
      // Edit mode
      _titleController.text = widget.exam!.title;
      _descriptionController.text = widget.exam!.description ?? '';
      _durationController.text = widget.exam!.durationMinutes.toString();
      _passingScoreController.text = widget.exam!.passingScore.toString();
      _examType = widget.exam!.examType;
      _isShuffled = widget.exam!.isShuffled;
      _isShuffleAnswers = widget.exam!.isShuffleAnswers;
      _showResultImmediately = widget.exam!.showResultImmediately;
      _allowReview = widget.exam!.allowReview;
    }

    _subjectsCubit.loadSubjects();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _passingScoreController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubject == null) {
      context.showSnackBar('Vui lòng chọn môn học', isError: true);
      return;
    }

    final request = CreateExamRequest(
      subjectId: _selectedSubject!.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      durationMinutes: int.tryParse(_durationController.text) ?? 60,
      passingScore: double.tryParse(_passingScoreController.text) ?? 5.0,
      examType: _examType,
      isShuffled: _isShuffled,
      isShuffleAnswers: _isShuffleAnswers,
      showResultImmediately: _showResultImmediately,
      allowReview: _allowReview,
    );

    if (widget.exam != null) {
      // Update
      await _examsCubit.updateExam(widget.exam!.id, request);
    } else {
      // Create
      await _examsCubit.createExam(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _examsCubit),
        BlocProvider.value(value: _subjectsCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ExamsCubit, ExamsState>(
            listener: (context, state) {
              state.maybeWhen(
                examCreated: (exam) {
                  context.showSnackBar('Tạo đề thi thành công');
                  // Navigate to add questions
                  context.router.replace(
                    SelectQuestionsRoute(examId: exam.id),
                  );
                },
                examUpdated: (exam) {
                  context.showSnackBar('Cập nhật đề thi thành công');
                  context.router.maybePop(true);
                },
                error: (message) {
                  context.showSnackBar(message, isError: true);
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<SubjectsCubit, SubjectsState>(
            listener: (context, state) {
              state.maybeWhen(
                loaded: (subjects) {
                  setState(() {
                    _subjects = subjects;
                    if (widget.exam != null) {
                      _selectedSubject = subjects.firstWhere(
                        (s) => s.id == widget.exam!.subjectId,
                        orElse: () => subjects.first,
                      );
                    } else if (widget.subjectId != null) {
                      _selectedSubject = subjects.firstWhere(
                        (s) => s.id == widget.subjectId,
                        orElse: () => subjects.first,
                      );
                    }
                  });
                },
                orElse: () {},
              );
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.exam != null ? 'Chỉnh sửa đề thi' : 'Tạo đề thi mới',
            ),
          ),
          body: BlocBuilder<ExamsCubit, ExamsState>(
            builder: (context, state) {
              final isLoading = state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Subject selection
                    DropdownButtonFormField<SubjectModel>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Môn học',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book_outlined),
                      ),
                      items: _subjects
                          .map(
                            (subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubject = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Vui lòng chọn môn học';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Title
                    CustomTextField(
                      controller: _titleController,
                      label: 'Tên đề thi',
                      hint: 'Nhập tên đề thi...',
                      prefixIcon: const Icon(Icons.title),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên đề thi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Mô tả (tùy chọn)',
                      hint: 'Nhập mô tả đề thi...',
                      maxLines: 3,
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    const SizedBox(height: 16),

                    // Exam type
                    DropdownButtonFormField<String>(
                      value: _examType,
                      decoration: const InputDecoration(
                        labelText: 'Loại đề thi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'REGULAR',
                          child: Text('Thường'),
                        ),
                        DropdownMenuItem(
                          value: 'MIDTERM',
                          child: Text('Giữa kỳ'),
                        ),
                        DropdownMenuItem(
                          value: 'FINAL',
                          child: Text('Cuối kỳ'),
                        ),
                        DropdownMenuItem(
                          value: 'PRACTICE',
                          child: Text('Luyện tập'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _examType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Duration and Passing Score in row
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _durationController,
                            label: 'Thời gian (phút)',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.timer_outlined),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nhập thời gian';
                              }
                              final duration = int.tryParse(value);
                              if (duration == null || duration <= 0) {
                                return 'Thời gian không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _passingScoreController,
                            label: 'Điểm đạt',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.grade_outlined),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nhập điểm đạt';
                              }
                              final score = double.tryParse(value);
                              if (score == null || score < 0 || score > 10) {
                                return 'Điểm: 0-10';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Settings section
                    const Text(
                      'Cài đặt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SwitchListTile(
                      title: const Text('Xáo trộn câu hỏi'),
                      subtitle: const Text(
                        'Thứ tự câu hỏi sẽ được xáo trộn cho mỗi học sinh',
                      ),
                      value: _isShuffled,
                      onChanged: (value) {
                        setState(() {
                          _isShuffled = value;
                        });
                      },
                    ),

                    SwitchListTile(
                      title: const Text('Xáo trộn đáp án'),
                      subtitle: const Text(
                        'Thứ tự đáp án sẽ được xáo trộn',
                      ),
                      value: _isShuffleAnswers,
                      onChanged: (value) {
                        setState(() {
                          _isShuffleAnswers = value;
                        });
                      },
                    ),

                    SwitchListTile(
                      title: const Text('Hiển thị kết quả ngay'),
                      subtitle: const Text(
                        'Học sinh sẽ thấy kết quả ngay sau khi nộp bài',
                      ),
                      value: _showResultImmediately,
                      onChanged: (value) {
                        setState(() {
                          _showResultImmediately = value;
                        });
                      },
                    ),

                    SwitchListTile(
                      title: const Text('Cho phép xem lại'),
                      subtitle: const Text(
                        'Học sinh có thể xem lại bài thi sau khi hoàn thành',
                      ),
                      value: _allowReview,
                      onChanged: (value) {
                        setState(() {
                          _allowReview = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Submit button
                    CustomButton(
                      text: widget.exam != null
                          ? 'Cập nhật'
                          : 'Tiếp tục (Chọn câu hỏi)',
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
