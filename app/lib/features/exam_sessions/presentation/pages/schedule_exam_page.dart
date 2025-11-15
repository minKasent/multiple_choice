import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../exams/data/models/exam_model.dart';
import '../../../exams/presentation/bloc/exams_cubit.dart';
import '../../../exams/presentation/bloc/exams_state.dart';
import '../../../users/data/models/user_model.dart';
import '../../../users/presentation/bloc/users_cubit.dart';
import '../../../users/presentation/bloc/users_state.dart';
import '../../data/models/exam_session_model.dart';
import '../bloc/exam_sessions_cubit.dart';
import '../bloc/exam_sessions_state.dart';

@RoutePage()
class ScheduleExamPage extends StatefulWidget {
  final ExamModel? exam; // Pre-selected exam (optional)

  const ScheduleExamPage({super.key, this.exam});

  @override
  State<ScheduleExamPage> createState() => _ScheduleExamPageState();
}

class _ScheduleExamPageState extends State<ScheduleExamPage> {
  late final ExamSessionsCubit _examSessionsCubit;
  late final ExamsCubit _examsCubit;
  late final UsersCubit _usersCubit;

  final _formKey = GlobalKey<FormState>();

  ExamModel? _selectedExam;
  final Set<int> _selectedStudentIds = {};
  DateTime? _selectedDateTime;

  List<ExamModel> _exams = [];
  List<UserModel> _students = [];

  @override
  void initState() {
    super.initState();
    _examSessionsCubit = getIt<ExamSessionsCubit>();
    _examsCubit = getIt<ExamsCubit>();
    _usersCubit = getIt<UsersCubit>();

    if (widget.exam != null) {
      _selectedExam = widget.exam;
    } else {
      _examsCubit.loadAllExams();
    }

    _usersCubit.loadUsersByRole('STUDENT');
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      final initialTime = isToday
          ? TimeOfDay.fromDateTime(now)
          : const TimeOfDay(hour: 9, minute: 0);

      final time = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (time != null && mounted) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          _selectedDateTime = selectedDateTime;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExam == null) {
      context.showSnackBar('Vui lòng chọn đề thi', isError: true);
      return;
    }

    if (_selectedStudentIds.isEmpty) {
      context.showSnackBar('Vui lòng chọn ít nhất 1 học sinh', isError: true);
      return;
    }

    if (_selectedDateTime == null) {
      context.showSnackBar('Vui lòng chọn thời gian', isError: true);
      return;
    }

    final request = ScheduleExamRequest(
      examId: _selectedExam!.id,
      studentIds: _selectedStudentIds.toList(),
      startTime: _selectedDateTime!,
    );

    await _examSessionsCubit.scheduleExam(request);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _examSessionsCubit),
        BlocProvider.value(value: _examsCubit),
        BlocProvider.value(value: _usersCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ExamSessionsCubit, ExamSessionsState>(
            listener: (context, state) {
              state.maybeWhen(
                scheduled: (sessions) {
                  context.showSnackBar(
                    'Đã lên lịch ${sessions.length} bài thi thành công',
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
          BlocListener<ExamsCubit, ExamsState>(
            listener: (context, state) {
              state.maybeWhen(
                examsLoaded: (exams) {
                  setState(() {
                    _exams = exams;
                    if (exams.isNotEmpty && _selectedExam == null) {
                      _selectedExam = exams.first;
                    }
                  });
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<UsersCubit, UsersState>(
            listener: (context, state) {
              state.maybeWhen(
                loaded: (users) {
                  setState(() {
                    _students = users;
                  });
                },
                orElse: () {},
              );
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(title: const Text('Lên lịch bài thi')),
          body: BlocBuilder<ExamSessionsCubit, ExamSessionsState>(
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
                    // Exam Selection
                    if (widget.exam == null) ...[
                      const Text(
                        'Chọn đề thi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<ExamModel>(
                        value: _selectedExam,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.assignment_outlined),
                        ),
                        items: _exams
                            .map(
                              (exam) => DropdownMenuItem(
                                value: exam,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      exam.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${exam.subjectName} - ${exam.totalQuestions} câu - ${exam.durationMinutes} phút',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedExam = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn đề thi';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Đề thi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedExam!.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedExam!.subjectName} - ${_selectedExam!.totalQuestions} câu - ${_selectedExam!.durationMinutes} phút',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // DateTime Selection
                    const Text(
                      'Thời gian bắt đầu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDateTime != null
                                  ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Chọn thời gian bắt đầu',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDateTime != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Students Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chọn học sinh',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_selectedStudentIds.isNotEmpty)
                          Text(
                            'Đã chọn: ${_selectedStudentIds.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_students.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('Chưa có học sinh nào'),
                        ),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 400),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _students.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final isSelected = _selectedStudentIds.contains(
                              student.id,
                            );

                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedStudentIds.add(student.id);
                                  } else {
                                    _selectedStudentIds.remove(student.id);
                                  }
                                });
                              },
                              title: Text(student.fullName),
                              subtitle: Text(student.email),
                              secondary: CircleAvatar(
                                child: Text(
                                  student.fullName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Summary Card
                    if (_selectedExam != null && _selectedStudentIds.isNotEmpty)
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sẽ tạo ${_selectedStudentIds.length} phiên thi cho đề "${_selectedExam!.title}"',
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (_selectedDateTime != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Thời gian: ${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Thời lượng: ${_selectedExam!.durationMinutes} phút',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Submit Button
                    CustomButton(
                      text: 'Lên lịch bài thi',
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
