import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/models/exam_model.dart';
import '../bloc/exams_cubit.dart';
import '../bloc/exams_state.dart';
import '../widgets/exam_card.dart';

@RoutePage()
class ExamsListPage extends StatefulWidget {
  final int? subjectId;

  const ExamsListPage({super.key, this.subjectId});

  @override
  State<ExamsListPage> createState() => _ExamsListPageState();
}

class _ExamsListPageState extends State<ExamsListPage> {
  late final ExamsCubit _cubit;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ExamsCubit>();
    _loadExams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadExams() {
    if (widget.subjectId != null) {
      _cubit.loadExamsBySubject(widget.subjectId!);
    } else {
      _cubit.loadAllExams();
    }
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      _loadExams();
      return;
    }
    _cubit.searchExams(query.trim());
  }

  Future<void> _showDeleteConfirmDialog(ExamModel exam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa đề thi "${exam.title}"?'),
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
      await _cubit.deleteExam(exam.id);
    }
  }

  Future<void> _showActionsMenu(ExamModel exam) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Xem chi tiết'),
              onTap: () {
                Navigator.pop(context);
                context.router.push(ExamDetailRoute(examId: exam.id));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context);
                context.router.push(CreateExamRoute(exam: exam));
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Nhân bản'),
              onTap: () async {
                Navigator.pop(context);
                await _cubit.cloneExam(exam.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shuffle),
              title: const Text('Xáo trộn câu hỏi'),
              onTap: () async {
                Navigator.pop(context);
                await _cubit.shuffleExam(exam.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(exam);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.subjectId != null ? 'Đề thi môn học' : 'Quản lý đề thi',
          ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _loadExams();
                  }
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm đề thi...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadExams();
                            },
                          )
                        : null,
                  ),
                  onChanged: _onSearch,
                ),
              ),
            Expanded(
              child: BlocConsumer<ExamsCubit, ExamsState>(
                listener: (context, state) {
                  state.maybeWhen(
                    examDeleted: () {
                      context.showSnackBar('Xóa đề thi thành công');
                      _loadExams();
                    },
                    examCloned: (exam) {
                      context.showSnackBar('Nhân bản đề thi thành công');
                      _loadExams();
                    },
                    examShuffled: (exam) {
                      context.showSnackBar('Xáo trộn đề thi thành công');
                    },
                    error: (message) {
                      context.showSnackBar(message, isError: true);
                    },
                    orElse: () {},
                  );
                },
                builder: (context, state) {
                  return state.maybeWhen(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    examsLoaded: (exams) {
                      if (exams.isEmpty) {
                        return Center(
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
                                'Chưa có đề thi nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async => _loadExams(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: exams.length,
                          itemBuilder: (context, index) {
                            final exam = exams[index];
                            return ExamCard(
                              exam: exam,
                              onTap: () => context.router.push(
                                ExamDetailRoute(examId: exam.id),
                              ),
                              onLongPress: () => _showActionsMenu(exam),
                            );
                          },
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.router.push(
              CreateExamRoute(subjectId: widget.subjectId),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Tạo đề thi'),
        ),
      ),
    );
  }
}

